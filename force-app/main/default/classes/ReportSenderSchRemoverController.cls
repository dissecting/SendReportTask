public with sharing class ReportSenderSchRemoverController {

    @AuraEnabled
    public static void removeSchedulable(Id recordId) {

        List<ReportSender__c> reportSender = [
            SELECT Id, Name, Cron__c
            FROM ReportSender__c
            WHERE Id = :recordId
        ];

        List<CronTrigger> jobList = new List<CronTrigger>();
        jobList = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name = :reportSender[0].Name
        ];

        for (CronTrigger job : jobList) {
            System.abortJob(job.id);
        }

        try {
            setCronStatus(reportSender);
        } catch (DMLException e){
            throw new AuraHandledException(e.getDMLMessage(0));
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }

    }

    private static void setCronStatus(List<ReportSender__c> reportSenderList) {

        for (ReportSender__c reportSender : reportSenderList) {
            reportSender.IsCron__c = false;
        }

        update reportSenderList;
    }

    @AuraEnabled
    public static Boolean checkCronStatus(Id recordId) {

        List<ReportSender__c> reportSender = [
            SELECT Id, Name, Cron__c, IsCron__c
            FROM ReportSender__c
            WHERE Id = :recordId
        ];

        Boolean isNotCron = !reportSender[0].IsCron__c;

        return isNotCron;
    }
}