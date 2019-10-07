public with sharing class ReportSenderController {

    @AuraEnabled
    public static void getReport(Id recordId) {

        List<ReportSender__c> reportSender = [
            SELECT Id, Name, Email__c
            FROM ReportSender__c
            WHERE Id = :recordId
        ];
        List<Report> reportList = [
            SELECT Id, Name
            FROM Report
            WHERE Name = :reportSender[0].Name
        ];

        if (!reportList.isEmpty()) {

            ReportAttributes reportAttributes = new ReportAttributes();

            String reportId = (String)reportList.get(0).get('Id');
            String emailName = reportSender[0].Email__c;
            String reportName = reportSender[0].Name;

            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
            Reports.Dimension dimension = results.getGroupingsDown();
            Reports.Dimension dimensionAcross = results.getGroupingsAcross();
            Reports.ReportExtendedMetadata reportExtendedMetadata  = results.getReportExtendedMetadata();
            Reports.ReportMetadata reportMetadata = results.getReportMetadata();
            Reports.ReportFormat reportFormat = reportMetadata.getReportFormat();

            Map<String,Reports.AggregateColumn> aggregateColumnMap = reportExtendedMetadata.getAggregateColumnInfo();
            Map<String,Reports.GroupingColumn> groupingColumnMap = reportExtendedMetadata.getGroupingColumnInfo();
            Map<String,Reports.DetailColumn> detailColumnInfoMap = reportExtendedMetadata.getDetailColumnInfo();

            List<Reports.GroupingValue> groupingValueList = dimension.getGroupings();
            List<String> aggregateColumnList = new List<String>();
            List<String> groupingColumnList = new List<String>();
            List<String> detailColumnList = new List<String>();
            List<String> factMapKey = new List<String>();
            List<String> groupingValueLabelList = new List<String>();
            List<String> summaryValueList = new List<String>();
            List<String> detailColumnValueList = new List<String>();
            List<String> detailColumnMatrixValueList = new List<String>();

            Integer columnSize = 0;
            Integer recordListSize = 0;

            for (String key : aggregateColumnMap.keySet()) {
                aggregateColumnList.add(aggregateColumnMap.get(key).getLabel());
            }

            for (String key : groupingColumnMap.keySet()) {
                groupingColumnList.add(groupingColumnMap.get(key).getLabel());
            }

            for (String key : detailColumnInfoMap.keySet()) {
                detailColumnList.add(detailColumnInfoMap.get(key).getLabel());
            }

            for (Reports.GroupingValue groupingValue : groupingValueList) {
                factMapKey.add(groupingValue.getKey());
            }

            if (String.valueOf(reportFormat) == 'SUMMARY') {
                reportAttributes = getSummaryReport(
                    results,
                    columnSize,
                    summaryValueList,
                    detailColumnValueList,
                    groupingValueLabelList,
                    factMapKey,
                    dimension
                );
            } else if (String.valueOf(reportFormat) == 'TABULAR') {
                reportAttributes = getTabularReport(
                    results,
                    columnSize,
                    summaryValueList,
                    detailColumnValueList
                );
            } else if (String.valueOf(reportFormat) == 'MATRIX') {
                String aggregateValue = aggregateColumnList[0];
                groupingValueList.addAll(dimensionAcross.getGroupings());
                aggregateColumnList[0] = groupingValueList[groupingValueList.size() - 1].getLabel();
                reportAttributes = getMatrixReport(
                    results,
                    columnSize,
                    summaryValueList,
                    detailColumnValueList,
                    groupingValueLabelList,
                    factMapKey,
                    recordListSize,
                    aggregateValue,
                    groupingValueList,
                    detailColumnMatrixValueList,
                    groupingColumnList
                );
            }

            String dataReport = prepareDataReport(
                reportAttributes.columnSize,
                reportAttributes.summaryValueList,
                reportAttributes.detailColumnValueList,
                reportAttributes.groupingValueLabelList,
                reportAttributes.recordListSize,
                aggregateColumnList,
                groupingColumnList,
                detailColumnList,
                detailColumnMatrixValueList,
                reportFormat
            );

            sendReportEmail(dataReport, emailName, reportName);
        } else {
            throw new AuraHandledException(Label.errMsgReportIsNotFound);
        }
    }

    private static ReportAttributes getTabularReport(Reports.reportResults results,
                                                    Integer columnSize,
                                                    List<String> summaryValueList,
                                                    List<String> detailColumnValueList) {

        ReportAttributes reportAttributes = new ReportAttributes();
        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');

        for (Integer i = 0; i < factDetails.getRows().size(); i++) {
            Reports.ReportDetailRow reportDetailRow = factDetails.getRows()[i];
            Reports.SummaryValue summaryValue = factDetails.getAggregates()[0];
            summaryValueList.add(summaryValue.getLabel());

            for (Integer j = 0; j < reportDetailRow.getDataCells().size(); j++) {
                detailColumnValueList.add(reportDetailRow.getDataCells()[j].getLabel());
            }

            columnSize = reportDetailRow.getDataCells().size();
        }

        reportAttributes.columnSize = columnSize;
        reportAttributes.summaryValueList = summaryValueList;
        reportAttributes.detailColumnValueList = detailColumnValueList;

        return reportAttributes;
    }

    private static ReportAttributes getSummaryReport(Reports.reportResults results,
                                                    Integer columnSize,
                                                    List<String> summaryValueList,
                                                    List<String> detailColumnValueList,
                                                    List<String> groupingValueLabelList,
                                                    List<String> factMapKey,
                                                    Reports.Dimension dimension) {

        ReportAttributes reportAttributes = new ReportAttributes();

        for (Integer i = 0; i < factMapKey.size(); i++) {
            Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey[i] + '!T');
            Reports.SummaryValue summaryValue = factDetails.getAggregates()[0];
            Reports.GroupingValue groupingValue = dimension.getGroupings()[i];

            for (Integer k = 0; k < factDetails.getRows().size(); k++) {
                Reports.ReportDetailRow reportDetailRow = factDetails.getRows()[k];

                for (Integer j = 0; j < reportDetailRow.getDataCells().size(); j++) {
                    detailColumnValueList.add(reportDetailRow.getDataCells()[j].getLabel());
                    if (k == 0) {
                        summaryValueList.add(summaryValue.getLabel());
                        groupingValueLabelList.add(groupingValue.getLabel());
                    } else {
                        summaryValueList.add('');
                        groupingValueLabelList.add('');
                    }
                }

                columnSize = reportDetailRow.getDataCells().size();
            }
        }

        reportAttributes.columnSize = columnSize;
        reportAttributes.summaryValueList = summaryValueList;
        reportAttributes.detailColumnValueList = detailColumnValueList;
        reportAttributes.groupingValueLabelList = groupingValueLabelList;

        return reportAttributes;
    }

    private static ReportAttributes getMatrixReport(Reports.reportResults results,
                                                    Integer columnSize,
                                                    List<String> summaryValueList,
                                                    List<String> detailColumnValueList,
                                                    List<String> groupingValueLabelList,
                                                    List<String> factMapKey,
                                                    Integer recordListSize,
                                                    String aggregateValue,
                                                    List<Reports.GroupingValue> groupingValueList,
                                                    List<String> detailColumnMatrixValueList,
                                                    List<String> groupingColumnList) {

        ReportAttributes reportAttributes = new ReportAttributes();

        for (Integer i = 0; i < factMapKey.size(); i++) {
            Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey[i] + '!T');
            Reports.SummaryValue summaryValue = factDetails.getAggregates()[0];
            groupingValueLabelList.add(groupingValueList[i].getLabel());
            summaryValueList.add(summaryValue.getLabel());
            detailColumnValueList.add(aggregateValue);
        }

        for (Integer i = 0; i < factMapKey.size(); i++) {
            Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey[i] + '!0');

            for (Integer k = 0; k < factDetails.getRows().size(); k++) {
                Reports.ReportDetailRow reportDetailRow = factDetails.getRows()[k];
                Reports.SummaryValue summaryValue = factDetails.getAggregates()[0];
                summaryValueList.add(summaryValue.getLabel());

                for (Integer j = 0; j < reportDetailRow.getDataCells().size(); j++) {
                    detailColumnMatrixValueList.add(reportDetailRow.getDataCells()[j].getLabel());
                }
            }
        }

        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!0');
        Reports.SummaryValue summaryValue = factDetails.getAggregates()[0];

        recordListSize = Integer.valueOf(summaryValue.getValue());
        columnSize = groupingColumnList.size();
        reportAttributes.columnSize = columnSize;
        reportAttributes.summaryValueList = summaryValueList;
        reportAttributes.detailColumnValueList = detailColumnValueList;
        reportAttributes.groupingValueLabelList = groupingValueLabelList;
        reportAttributes.detailColumnMatrixValueList = detailColumnMatrixValueList;
        reportAttributes.recordListSize = recordListSize;

        return reportAttributes;
    }

    private static String prepareDataReport(Integer columnSize,
                                            List<String> summaryValueList,
                                            List<String> detailColumnValueList,
                                            List<String> groupingValueLabelList,
                                            Integer recordListSize,
                                            List<String> aggregateColumnList,
                                            List<String> groupingColumnList,
                                            List<String> detailColumnList,
                                            List<String> detailColumnMatrixValueList,
                                            Reports.ReportFormat reportFormat) {

        String resultsSerialize = '';
        Integer colSizeIterator = 0;
        Integer matrixListSize = recordListSize;
        Integer recordsSize = groupingValueLabelList.size() > summaryValueList.size() ? groupingValueLabelList.size() : summaryValueList.size();
        Integer columnListSize = groupingColumnList.size() > aggregateColumnList.size() ? groupingColumnList.size() : aggregateColumnList.size();

        recordListSize = recordListSize > recordsSize ? recordListSize : recordsSize;

        if (columnSize > 0) {
            recordListSize = recordListSize > detailColumnValueList.size() / columnSize ? recordListSize : detailColumnValueList.size() / columnSize;
        }

        for (Integer i = 0; i < columnListSize; i++) {
            if (i < aggregateColumnList.size()) {
                resultsSerialize += aggregateColumnList[i] + ',';
            }
            if (i < groupingColumnList.size()) {
                resultsSerialize += groupingColumnList[i] + ',';
            }
        }

        for (Integer i = 0; i < columnSize; i++) {
            resultsSerialize += detailColumnList[i] + ',';
        }

        for (Integer i = 0; i < recordListSize; i++) {
            resultsSerialize += '\n';

            if (i < summaryValueList.size()) {
                resultsSerialize += summaryValueList[i] + ',';
            } else if (summaryValueList.size() > 0) {
                resultsSerialize += ',';
            }

            if (i < groupingValueLabelList.size()) {
                resultsSerialize += groupingValueLabelList[i] + ',';
            } else if (groupingValueLabelList.size() > 0)  {
                resultsSerialize += ',';
            }

            if (i < detailColumnValueList.size()) {
                if (String.valueOf(reportFormat) == 'MATRIX') {
                    resultsSerialize += detailColumnValueList[i] + ',';
                } else {
                    for (Integer j = 0 + colSizeIterator; j < columnSize + colSizeIterator; j++) {
                        resultsSerialize += detailColumnValueList[j] + ',';
                    }
                    colSizeIterator += columnSize;
                }
            } else if (detailColumnValueList.size() > 0) {
                resultsSerialize += ',';
            }

            if (String.valueOf(reportFormat) == 'MATRIX') {
                if (i >= detailColumnValueList.size()) {
                    for (Integer j = 0 + colSizeIterator; j < columnSize + colSizeIterator; j++) {
                        resultsSerialize += detailColumnMatrixValueList[j] + ',';
                    }
                    colSizeIterator += columnSize;
                } else if (matrixListSize > 0) {
                    resultsSerialize += ',';
                }
            }
        }

        return resultsSerialize;
    }

    private static void sendReportEmail(String dataReport, String emailName, String reportName) {

        Blob newFile = Blob.valueOf(dataReport);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

        efa.setFileName('report.csv');
        efa.setBody(newFile);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{emailName};

        email.setSubject(reportName);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody(reportName);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

    public class ReportAttributes {

        public Integer columnSize { get; set; }
        public List<String> summaryValueList { get; set; }
        public List<String> detailColumnValueList { get; set; }
        public List<String> groupingValueLabelList { get; set; }
        public List<String> detailColumnMatrixValueList { get; set; }
        public Integer recordListSize { get; set; }

        public ReportAttributes() {
            summaryValueList = new List<String>();
            detailColumnValueList = new List<String>();
            groupingValueLabelList = new List<String>();
            detailColumnMatrixValueList = new List<String>();
        }
    }
}