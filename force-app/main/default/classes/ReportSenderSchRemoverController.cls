public class ReportSenderSchRemoverController {

    @AuraEnabled
    public static void removeSchedulable(Id recordId) {

        List<ReportSender__c> reportSender = [
            SELECT Id, Name, Cron__c, IsCron__c
            FROM ReportSender__c
            WHERE Id = :recordId
        ];

        if (reportSender.isEmpty()) {
            throw new AuraHandledException(Label.errMsgReportIsNotFound);
        } else {
            Boolean isCron = reportSender[0].IsCron__c;

            if (!isCron) {
                throw new AuraHandledException(Label.SchedulableDoesNotExist);
            }

            List<CronTrigger> jobList = [
                SELECT Id, CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name = :reportSender[0].Name
            ];

            for (CronTrigger job : jobList) {
                System.abortJob(job.id);
            }

            ReportSenderSchRemoverController.setCronStatus(reportSender);
        }
    }

    private static void setCronStatus(List<ReportSender__c> reportSenderList) {

        for (ReportSender__c reportSender : reportSenderList) {
            reportSender.IsCron__c = false;
        }

        update reportSenderList;
    }
}