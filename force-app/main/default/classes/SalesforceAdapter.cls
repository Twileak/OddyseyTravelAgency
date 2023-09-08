global class SalesforceAdapter implements CommercePayments.PaymentGatewayAdapter {

    public static final CommercePayments.SalesforceResultCodeInfo SUCCESS_SALESFORCE_RESULT_CODE_INFO =
            new CommercePayments.SalesforceResultCodeInfo(CommercePayments.SalesforceResultCode.Success);
    public static final CommercePayments.SalesforceResultCodeInfo DECLINE_SALESFORCE_RESULT_CODE_INFO =
            new CommercePayments.SalesforceResultCodeInfo(CommercePayments.SalesforceResultCode.Decline);

    global SalesforceAdapter() {
    }

    global CommercePayments.GatewayResponse processRequest(CommercePayments.PaymentGatewayContext gatewayContext) {
        CommercePayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        CommercePayments.GatewayResponse response;
        try
        {
            if (requestType == CommercePayments.RequestType.Authorize) {

                response = createAuthResponse((CommercePayments.AuthorizationRequest)gatewayContext.getPaymentRequest());
            }
            else if ( requestType == CommercePayments.RequestType.Capture)
            {
                response =  createCaptureResponse((CommercePayments.CaptureRequest)gatewayContext.getPaymentRequest()) ;
            }
            else if ( requestType == CommercePayments.RequestType.Sale)
            {
                response =  createSaleResponse((CommercePayments.SaleRequest)gatewayContext.getPaymentRequest()) ;
            }
            else if (requestType == CommercePayments.RequestType.ReferencedRefund) {
                response = createRefundResponse((CommercePayments.ReferencedRefundRequest)gatewayContext.getPaymentRequest());
            }
            else if (requestType == CommercePayments.RequestType.Tokenize) {
                response = createTokenizeResponse((CommercePayments.PaymentMethodTokenizationRequest)gatewayContext.getPaymentRequest());
            }
            return response;
        }
        catch(SalesforceValidationException e)
        {
            CommercePayments.GatewayErrorResponse error = new CommercePayments.GatewayErrorResponse('400', e.getMessage());
            return error;
        }
    }

    public CommercePayments.GatewayResponse createTokenizeResponse(CommercePayments.PaymentMethodTokenizationRequest tokenizeRequest) {
        CommercePayments.PaymentMethodTokenizationResponse tokenizeResponse = new CommercePayments.PaymentMethodTokenizationResponse();
        tokenizeResponse.setGatewayToken(getRandomNumber(8)+getRandomNumber(8));
        tokenizeResponse.setGatewayTokenDetails(getRandomNumber(8)+getRandomNumber(8));
        tokenizeResponse.setGatewayAvsCode(getRandomNumber(8)+getRandomNumber(8));
        tokenizeResponse.setGatewayMessage(getRandomNumber(8)+getRandomNumber(8));
        tokenizeResponse.setGatewayResultCode(getRandomNumber(8)+getRandomNumber(8));
        tokenizeResponse.setGatewayResultCodeDescription(getRandomNumber(8)+getRandomNumber(8));
        tokenizeResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        tokenizeResponse.setGatewayToken(getRandomNumber(8)+getRandomNumber(8));
        tokenizeResponse.setGatewayDate(System.now());
        return tokenizeResponse;
    }

    public CommercePayments.GatewayResponse createAuthResponse(CommercePayments.AuthorizationRequest authRequest) {
        CommercePayments.AuthorizationResponse authResponse = new CommercePayments.AuthorizationResponse();
        CommercePayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new CommercePayments.PaymentMethodTokenizationResponse();
        if(authRequest.amount!=null )
        {
            authResponse.setAmount(authRequest.amount);
        }
        else
        {
            throw new SalesforceValidationException('Required Field Missing : Amount');
        }

        authResponse.setGatewayResultCode('00');
        authResponse.setGatewayResultCodeDescription('Transaction Normal');
        authResponse.setGatewayAuthCode('SF'+getRandomNumber(6));
        authResponse.setGatewayReferenceNumber(getRandomNumber(10));
        authResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        authResponse.setGatewayDate(System.now());
        paymentMethodTokenizationResponse.setGatewayToken(getRandomNumber(8)+getRandomNumber(8));
        authResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);
        return authResponse;
    }

    public CommercePayments.GatewayResponse createCaptureResponse(CommercePayments.CaptureRequest captureRequest) {
        CommercePayments.CaptureResponse captureResponse = new CommercePayments.CaptureResponse();
        if(captureRequest.amount!=null )
        {
            captureResponse.setAmount(captureRequest.amount);
        }
        else
        {
            throw new SalesforceValidationException('Required Field Missing : Amount');
        }

        captureResponse.setGatewayDate(System.now());
        captureResponse.setGatewayResultCode('00');
        captureResponse.setGatewayResultCodeDescription('Transaction Normal');
        captureResponse.setGatewayReferenceNumber('SF'+getRandomNumber(6));
        captureResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        return captureResponse;
    }

    public CommercePayments.GatewayResponse createSaleResponse(CommercePayments.SaleRequest saleRequest) {
        CommercePayments.SaleResponse saleResponse = new CommercePayments.SaleResponse();
        CommercePayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new CommercePayments.PaymentMethodTokenizationResponse();
        if(saleRequest.amount!=null )
        {
            saleResponse.setAmount(saleRequest.amount);
        }
        else
        {
            throw new SalesforceValidationException('Required Field Missing : Amount');
        }

        saleResponse.setGatewayDate(System.now());
        saleResponse.setGatewayResultCode('00');
        saleResponse.setGatewayResultCodeDescription('Transaction Normal');
        saleResponse.setGatewayReferenceNumber('SF'+getRandomNumber(6));
        saleResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        paymentMethodTokenizationResponse.setGatewayToken(getRandomNumber(8)+getRandomNumber(8));
        saleResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);
        return saleResponse;
    }

    public CommercePayments.GatewayResponse createRefundResponse(CommercePayments.ReferencedRefundRequest refundRequest) {
        CommercePayments.ReferencedRefundResponse refundResponse = new CommercePayments.ReferencedRefundResponse();
        if (refundRequest.amount != null) {
            refundResponse.setAmount(refundRequest.amount);
        } else {
            throw new SalesforceValidationException('Required Field Missing : Amount');
        }
        refundResponse.setGatewayResultCode('00');
        refundResponse.setGatewayDate(System.now());
        refundResponse.setGatewayResultCodeDescription('Transaction Normal');
        refundResponse.setGatewayReferenceNumber('SF'+getRandomNumber(6));
        refundResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        return refundResponse;
    }
    private String getRandomNumber(Integer stringLength){
        final Integer MAX = Integer.valueOf(Math.pow(10,stringLength) - 1);
        return String.valueOf(Math.round(Math.random() * MAX)).leftPad(stringLength,'0');
    }
}