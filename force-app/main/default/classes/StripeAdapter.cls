global class StripeAdapter implements CommercePayments.PaymentGatewayAdapter {

    private static final CommercePayments.SalesforceResultCodeInfo RC_SUCCESS = toCodeInfo(CommercePayments.SalesforceResultCode.Success);
    private static final CommercePayments.SalesforceResultCodeInfo RC_DECLINE = toCodeInfo(CommercePayments.SalesforceResultCode.Decline);
    private static final List<String> DECLINE_CODES = new List<String>{'card_declined', 'incorrect_cvc', 'expired_card',
            'authentication_required', 'card_not_supported', 'currency_not_supported', 'incorrect_number', 'incorrect_zip'};

    global StripeAdapter() {
    }

    global CommercePayments.GatewayResponse processRequest(CommercePayments.PaymentGatewayContext gatewayContext) {
        CommercePayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        CommercePayments.PaymentGatewayRequest paymentRequest = gatewayContext.getPaymentRequest();
        CommercePayments.GatewayResponse response;

        try {
            if (requestType == CommercePayments.RequestType.Authorize) {
                response = createAuthResponse((CommercePayments.AuthorizationRequest) paymentRequest);
            } else if (requestType == CommercePayments.RequestType.Capture) {
                response =  createCaptureResponse((CommercePayments.CaptureRequest) paymentRequest);
            } else if (requestType == CommercePayments.RequestType.Sale) {
                response =  createSaleResponse((CommercePayments.SaleRequest) paymentRequest);
            } else if (requestType == CommercePayments.RequestType.ReferencedRefund) {
                response = createRefundResponse((CommercePayments.ReferencedRefundRequest) paymentRequest);
            } else if (requestType == CommercePayments.RequestType.Tokenize) {
                response = createTokenizeResponse((CommercePayments.PaymentMethodTokenizationRequest) paymentRequest);
            }
            return response;
        } catch (StripeValidationException e) {
            return new CommercePayments.GatewayErrorResponse('400', e.getMessage());
        }
    }

    public CommercePayments.GatewayResponse createTokenizeResponse(CommercePayments.PaymentMethodTokenizationRequest tokenizeRequest) {

        CommercePayments.CardPaymentMethodRequest cardPaymentMethod = tokenizeRequest.cardPaymentMethod;

        Map<String, String> params = new Map<String, String>();
        params.put('card[name]', urlEncode(cardPaymentMethod.cardHolderName));
        params.put('card[number]', cardPaymentMethod.cardNumber);
        params.put('card[exp_month]', String.valueOf(cardPaymentMethod.expiryMonth));
        params.put('card[exp_year]', String.valueOf(cardPaymentMethod.expiryYear));
        params.put('card[cvc]', cardPaymentMethod.cvv);

        CommercePayments.AddressRequest billingAddress = tokenizeRequest.address;

        if (billingAddress != null) {
            params.put('card[address_line1]', billingAddress.street);
            params.put('card[address_city]', billingAddress.city);
            params.put('card[address_state]', billingAddress.state);
            params.put('card[address_zip]', billingAddress.postalCode);
            params.put('card[address_country]', billingAddress.country);
        }

        HttpResponse response = doPost('tokens', params);
        String body = response.getBody();
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
        Integer sc = response.getStatusCode();
        CommercePayments.PaymentMethodTokenizationResponse tokenizeResponse = new CommercePayments.PaymentMethodTokenizationResponse();

        tokenizeResponse.setGatewayDate(System.now());

        if (sc >= 200 && sc < 300) {
            tokenizeResponse.setGatewayToken((String) results.get('id'));
            tokenizeResponse.setGatewayResultCode('success');
            tokenizeResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
        }
        else {
            Map<String, Object> error = (Map<String, Object>) results.get('error');
            String errorType = (String) error.get('type');
            String errorCode = (String) error.get('code');

            if (errorType.equals('card_error') && DECLINE_CODES.contains(errorCode) ) {
                tokenizeResponse.setGatewayResultCode(errorCode);
                tokenizeResponse.setGatewayResultCodeDescription((String) error.get('decline_code'));
                tokenizeResponse.setGatewayMessage((String) error.get('message'));
                tokenizeResponse.setSalesforceResultCodeInfo(RC_DECLINE);
            } else {
                return new CommercePayments.GatewayErrorResponse(String.valueOf(sc), 'ERROR: ' + body);
            }
        }

        return tokenizeResponse;
    }

    public CommercePayments.GatewayResponse createAuthResponse(CommercePayments.AuthorizationRequest authRequest) {
        CommercePayments.AuthApiPaymentMethodRequest paymentMethod = authRequest.paymentMethod;

        QueryUtils q = new QueryUtils(CardPaymentMethod.SObjectType);
        q.getSelectClause().addField('GatewayToken', false);
        q.setWhereClause(' WHERE Id =' + '\'' + paymentMethod.id + '\'');
        CardPaymentMethod cardPaymentMethod = (CardPaymentMethod)Database.query(q.buildSOQL())[0];

        String currencyIsoCodeLC = authRequest.currencyIsoCode.toLowerCase();
        Long amount = toStripeCurrencyUnits(currencyIsoCodeLC, authRequest.amount);

        Map<String, String> params = new Map<String, String>();
        params.put('amount', String.valueOf(amount));
        params.put('currency', currencyIsoCodeLC);
        params.put('source', urlEncode(cardPaymentMethod.GatewayToken));
        params.put('capture', 'false');

        HttpResponse response = doPost('charges', params);
        String body = response.getBody();
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
        Integer sc = response.getStatusCode();
        CommercePayments.AuthorizationResponse authResponse = new CommercePayments.AuthorizationResponse();

        authResponse.setGatewayDate(System.now());

        if (sc >= 200 && sc < 300) {
            authResponse.setGatewayResultCode((String) results.get('status'));
            authResponse.setGatewayResultCodeDescription((String) results.get('status'));
            authResponse.setGatewayAuthCode((String) results.get('id'));
            authResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
            authResponse.setAmount(Double.valueOf(((Long) results.get('amount'))/100.00));
        } else {
            Map<String, Object> error = (Map<String, Object>) results.get('error');
            String errorType = (String) error.get('type');
            String errorCode = (String) error.get('code');

            if (errorType.equals('card_error') && DECLINE_CODES.contains(errorCode) ) {
                authResponse.setGatewayResultCode(errorCode);
                authResponse.setGatewayResultCodeDescription((String) error.get('decline_code'));
                authResponse.setGatewayMessage((String) error.get('message'));
                authResponse.setSalesforceResultCodeInfo(RC_DECLINE);
            } else {
                return new CommercePayments.GatewayErrorResponse(String.valueOf(sc), 'ERROR: ' + body);
            }
        }

        return authResponse;
    }

    public CommercePayments.GatewayResponse createCaptureResponse(CommercePayments.CaptureRequest captureRequest) {

        QueryUtils q = new QueryUtils(PaymentAuthorization.SObjectType);
        q.getSelectClause().addField('GatewayAuthCode', false);
        q.setWhereClause(' WHERE Id =' + '\'' + captureRequest.paymentAuthorizationId + '\'');
        PaymentAuthorization paymentAuthorization = (PaymentAuthorization)Database.query(q.buildSOQL())[0];
        String authCode = paymentAuthorization.GatewayAuthCode;

        String currencyIsoCodeLC = 'usd';
        Long amount = toStripeCurrencyUnits(currencyIsoCodeLC, captureRequest.amount);

        Map<String, String> params = new Map<String, String>();
        params.put('amount', String.valueOf(amount));

        HttpResponse response = doPost('charges/' + authCode + '/capture', params);

        String body = response.getBody();
        if (response.getStatusCode() != 200) {
            return new CommercePayments.GatewayErrorResponse('500', 'ERROR: ' + response + ': ' + body);
        }
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);

        CommercePayments.CaptureResponse captureResponse = new CommercePayments.CaptureResponse();
        captureResponse.setAmount(Double.valueOf(((Long) results.get('amount'))/100.00));
        captureResponse.setGatewayDate(System.now());
        captureResponse.setGatewayResultCode((String) results.get('balance_transaction'));
        captureResponse.setGatewayResultCodeDescription((String) results.get('receipt_url'));
        captureResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
        return captureResponse;
    }

    public CommercePayments.GatewayResponse createSaleResponse(CommercePayments.SaleRequest saleRequest) {
        throw new StripeValidationException('TODO: createSaleResponse');
    }

    public CommercePayments.GatewayResponse createRefundResponse(CommercePayments.ReferencedRefundRequest refundRequest) {
        QueryUtils q = new QueryUtils(Payment.SObjectType);
        q.getSelectClause().addField('PaymentAuthorizationId', false);
        q.setWhereClause(' WHERE Id =' + '\'' + refundRequest.paymentId + '\'');
        Payment payment = (Payment)Database.query(q.buildSOQL())[0];

        QueryUtils q1 = new QueryUtils(PaymentAuthorization.SObjectType);
        q1.getSelectClause().addField('GatewayAuthCode', false);
        q1.setWhereClause(' WHERE Id =' + '\'' + payment.PaymentAuthorizationId + '\'');
        PaymentAuthorization paymentAuth = (PaymentAuthorization)Database.query(q1.buildSOQL())[0];

        String currencyIsoCodeLC = 'usd';
        Long amount = toStripeCurrencyUnits(currencyIsoCodeLC, refundRequest.amount);

        Map<String, String> params = new Map<String, String>();
        params.put('charge', paymentAuth.GatewayAuthCode);
        params.put('amount', String.valueOf(amount));

        HttpResponse response = doPost('refunds', params);

        String body = response.getBody();
        if (response.getStatusCode() != 200) {
            return new CommercePayments.GatewayErrorResponse('500', 'ERROR: ' + response + ': ' + body);
        }
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);

        CommercePayments.ReferencedRefundResponse refundResponse = new CommercePayments.ReferencedRefundResponse();
        refundResponse.setAmount(Double.valueOf(((Long) results.get('amount'))/100.00));
        refundResponse.setGatewayDate(System.now());
        refundResponse.setGatewayResultCode((String) results.get('balance_transaction'));
        refundResponse.setGatewayResultCodeDescription((String) results.get('receipt_url'));
        refundResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
        return refundResponse;
    }

    private static HttpResponse doPost(String path, Map<String, String> params) {
        CommercePayments.PaymentsHttp http = new CommercePayments.PaymentsHttp();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('/v1/' + path);

        Blob headerValue = Blob.valueOf('{!$Credential.Username}');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);

        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(urlEncodedParams(params));

        return http.send(request);
    }

    private static String urlEncodedParams(Map<String, String> params) {
        String body = '';
        Boolean first = true;
        for (String key: params.keySet()) {
            if (first) {
                first = false;
            } else {
                body += '&';
            }
            body += urlEncode(key) + '=' + params.get(key);
        }
        return body;
    }

    private static String urlEncode(String str) {
        return EncodingUtil.urlEncode(str, 'UTF-8');
    }

    private static Long toStripeCurrencyUnits(String currencyIsoCodeLC, Double amount) {
        if (currencyIsoCodeLC.equals('usd')) {
            return Math.roundToLong(amount * 100);
        }
        throw new StripeValidationException('toStripeCurrencyUnits: TODO: ' + currencyIsoCodeLC);
    }

    private static CommercePayments.SalesforceResultCodeInfo toCodeInfo(CommercePayments.SalesforceResultCode code) {
        return new CommercePayments.SalesforceResultCodeInfo(code);
    }
}