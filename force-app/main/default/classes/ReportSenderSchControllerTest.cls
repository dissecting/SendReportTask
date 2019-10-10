@isTest
private class ReportSenderSchControllerTest {

    @isTest(SeeAllData = 'true')
    static void testSetSchedulable() {

        ReportSender__c reportSender = new ReportSender__c (
            Report_Name__c = 'Three most popular skills',
            Cron__c = '0 58 11 * * ? *',
            IsCron__c = false,
            Email__c = 'test@gmail.com'
        );

        insert reportSender;

        Test.startTest();
            ReportSenderSchController.setSchedulable(reportSender.Id);
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

        System.assertEquals(1, jobList.size());
        System.assertEquals(true, reportSenderList[0].IsCron__c);
    }

    @isTest
    static void testSetIncorrectSchedulable() {
        ReportSender__c reportSender = new ReportSender__c (
            Report_Name__c = 'Test',
            Cron__c = 'Test',
            Email__c = 'test@gmail.com'
        );

        insert reportSender;

        Test.startTest();
            try {
                ReportSenderSchController.setSchedulable(reportSender.Id);
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e.getMessage());
            }
        Test.stopTest();

    }

    @isTest
    static void testCheckIncorrectSchedulableStatus() {

        ReportSender__c reportSender = new ReportSender__c (
            Report_Name__c = 'Three most popular skills',
            Cron__c = '0 58 11 * * ? *',
            IsCron__c = true,
            Email__c = 'test@gmail.com'
        );

        insert reportSender;

        Test.startTest();
            try {
                ReportSenderSchController.setSchedulable(reportSender.Id);
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    static void testSetNullRecordId() {

        Test.startTest();
            try {
                ReportSenderSchController.setSchedulable(null);
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e.getMessage());
            }
        Test.stopTest();
    }
}