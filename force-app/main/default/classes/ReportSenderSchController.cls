public class ReportSenderSchController {

    @AuraEnabled
    public static void setSchedulable(Id recordId) {

        List<ReportSender__c> reportSender = [
            SELECT Id, Name, Cron__c, IsCron__c, Report_Name__c
            FROM ReportSender__c
            WHERE Id = :recordId
        ];

        if (reportSender.isEmpty()) {
            throw new AuraHandledException(Label.errMsgReportIsNotFound);
        } else {
            String cronValue = reportSender[0].Cron__c;
            String reportSenderName = reportSender[0].Name;
            Boolean isCron = reportSender[0].IsCron__c;

            if (isCron) {
                throw new AuraHandledException(Label.SchedulableAlreadyExists);
            }

            try {
                System.schedule(reportSenderName, cronValue, new ReportSenderSch(recordId));
                ReportSenderSchController.setSchedulableStatus(reportSender);
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    private static void setSchedulableStatus(List<ReportSender__c> reportSenderList) {

        for (ReportSender__c reportSender : reportSenderList) {
            reportSender.IsCron__c = true;
        }

        update reportSenderList;
    }
}