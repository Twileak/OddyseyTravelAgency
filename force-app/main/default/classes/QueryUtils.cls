public class QueryUtils
{
    public Schema.SObjectType table {get; private set;}
    private Boolean enforceFLS;
    private SelectClause selectClause;
    private FromClause fromClause;
    private String whereClause;
    public QueryUtils(Schema.SObjectType table)
    {
        this.table = table;
        enforceFLS = false;
        selectClause = new SelectClause(table, enforceFLS);
        fromClause = new FromClause(table.getDescribe().getName());
    }
    public SelectClause getSelectClause()
    {
        return selectClause;
    }
    public String buildSOQL()
    {
        String soql = selectClause.buildSOQL();
        soql += (' ' + fromClause.buildSOQL());
        if(whereClause!=null){
            soql +=(' ' + whereClause);
        }
        String rt = soql.trim();
        return rt;
    }
    private static String join(List<Expression> values, String separator)
    {
        if ((values == null) || (values.size() == 0))
        {
            return '';
        }
        if (separator == null)
        {
            separator = '';
        }

        String result = '';
        for (Expression value : values)
        {
            if (value == null)
            {
                continue;
            }
            String fragment = value.buildSOQL();
            if (value instanceof QueryUtils)
            {
                fragment = '(' + fragment + ')';
            }
            result += (fragment + separator);
        }
        result = result.substring(0,result.length() - separator.length());
        return result;
    }
    public interface Expression
    {
        String buildSOQL();
    }
    public abstract class ComplexExpression implements Expression
    {
        private List<Expression> expressions = new List<Expression>();
        public ComplexExpression addExpression(Expression expr)
        {
            if (expr != null)
            {
                expressions.add(expr);
            }
            return this;
        }
        public List<Expression> getExpressions()
        {
            return expressions;
        }
    }
    public class FieldExpression implements Expression
    {
        private String field;
        private String relationship;
        private Boolean translatable;
        public FieldExpression(String relationship, String field, Boolean translatable)
        {
            this.field = field;
            this.relationship = relationship;
            this.translatable = translatable;
        }

        public FieldExpression(String field, Boolean translatable)
        {
            this(null, field, translatable);
        }
        public String buildSOQL()
        {
            String fieldValue = '';
            if (relationship != null)
            {
                fieldValue = relationship + '.' + field;
            }
            else
            {
                fieldValue = field;
            }

            if ( translatable )
            {
                fieldValue = 'toLabel(' + fieldValue + ')';
            }

            return fieldValue;
        }
    }
    public class SelectClause extends ComplexExpression
    {
        private Set<String> existing = new Set<String>();
        private Schema.SObjectType table;
        private Boolean enforceFLS;

        public SelectClause(Schema.SObjectType table, Boolean enforceFLS)
        {
            super();
            this.table = table;
            this.enforceFLS = enforceFLS;
        }
        public SelectClause addField(SObjectField field)
        {
            Schema.DescribeFieldResult describeFieldResultInstance = field.getDescribe();
            if (describeFieldResultInstance.isAccessible())
            {
                addField(describeFieldResultInstance.getName(), toTranslate(field));
                existing.add(describeFieldResultInstance.getName().toLowerCase());
            }
            return this;
        }
        public SelectClause addFields(Schema.SObjectField[] fields)
        {
            for (Schema.SObjectField field : fields)
            {
                addField(field);
            }
            return this;
        }

        public SelectClause addField(String field, Boolean translatable)
        {
            if (!existing.contains(field.toLowerCase())) {
                addExpression(new FieldExpression(field, translatable));
                existing.add(field.toLowerCase());
            }
            return this;
        }
        public String buildSOQL()
        {
            return 'SELECT ' + QueryUtils.join(getExpressions(), ',');
        }
        public Boolean toTranslate(Schema.SObjectField field )
        {
            Set<Schema.DisplayType> translatableTypeList = new Set<Schema.DisplayType>
            {
                    Schema.DisplayType.MULTIPICKLIST,
                    Schema.DisplayType.PICKLIST
            };

            return translatableTypeList.contains(field.getDescribe().getType());
        }
    }
    public class FromClause implements Expression
    {
        private String objectName;
        public FromClause(String objectName)
        {
            this.objectName = objectName;
        }
        public String buildSOQL()
        {
            return 'FROM ' + objectName;
        }
    }
    public void setWhereClause(String whereClause){
        this.whereClause = whereClause;
    }
}