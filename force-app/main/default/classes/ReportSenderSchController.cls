public class ReportSenderSchController {

    @AuraEnabled
    public static void setSchedulable(Id recordId) {

        List<ReportSender__c> reportSender = [
            SELECT Id, Name, Cron__c
            FROM ReportSender__c
            WHERE Id = :recordId
        ];

        String cronValue = reportSender[0].Cron__c;
        String reportName = reportSender[0].Name;

        try {
            System.schedule(reportName, cronValue, new ReportSenderSch(recordId));
            setSchedulableStatus(reportSender);
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }

    }

    private static void setSchedulableStatus(List<ReportSender__c> reportSenderList) {

        for (ReportSender__c reportSender : reportSenderList) {
            reportSender.IsCron__c = true;
        }

        update reportSenderList;
    }

    @AuraEnabled
    public static Boolean checkSchedulableStatus(Id recordId) {

        List<ReportSender__c> reportSender = [
            SELECT Id, Name, Cron__c, IsCron__c
            FROM ReportSender__c
            WHERE Id = :recordId
        ];

        Boolean isCron = reportSender[0].IsCron__c;

        if (isCron) {
            throw new AuraHandledException(Label.SchedulableAlreadyExists);
        }

        return isCron;
    }
}