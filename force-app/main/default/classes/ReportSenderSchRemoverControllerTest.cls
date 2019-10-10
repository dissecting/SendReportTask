@isTest
private class ReportSenderSchRemoverControllerTest {

    @isTest(SeeAllData = 'true')
    static void testRemoveSchedulable() {

        ReportSender__c reportSender = new ReportSender__c (
            Report_Name__c = 'Three most popular skills',
            Cron__c = '0 58 11 * * ? *',
            IsCron__c = false,
            Email__c = 'test@gmail.com'
        );

        insert reportSender;

        ReportSenderSchController.setSchedulable(reportSender.Id);

        Test.startTest();
            ReportSenderSchRemoverController.removeSchedulable(reportSender.Id);
        Test.stopTest();

        List<CronTrigger> jobList = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
        ];

        List<ReportSender__c> reportSenderList = [
            SELECT Id, Name, Cron__c, IsCron__c
            FROM ReportSender__c
            WHERE Id = :reportSender.Id
        ];

        System.assertEquals(0, jobList.size());
        System.assertEquals(false, reportSenderList[0].IsCron__c);
    }

    @isTest
    static void testCheckIncorrectCronStatus() {

        ReportSender__c reportSender = new ReportSender__c (
            Report_Name__c = 'Three most popular skills',
            Cron__c = '0 58 11 * * ? *',
            IsCron__c = false,
            Email__c = 'test@gmail.com'
        );

        insert reportSender;

        Test.startTest();
            try {
                ReportSenderSchRemoverController.removeSchedulable(reportSender.Id);
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    static void testSetNullRecordId() {

        Test.startTest();
            try {
                ReportSenderSchRemoverController.removeSchedulable(null);
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e.getMessage());
            }
        Test.stopTest();
    }
}