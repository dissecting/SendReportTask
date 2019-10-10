@isTest
private class ReportSenderControllerTest {

    @isTest(SeeAllData = 'true')
    static void testSendSummaryReport() {
        ReportSender__c reportSender = new ReportSender__c (
            Report_Name__c = 'Three most popular skills',
            Cron__c = '0 58 11 * * ? *',
            Email__c = 'test@gmail.com'
        );

        insert reportSender;

        List<Report> reportList = [
            SELECT Id, Name
            FROM Report
            WHERE Name = :reportSender.Report_Name__c
        ];

        String reportId = (String)reportList.get(0).get('Id');

        Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
        Reports.ReportMetadata reportMetadata = results.getReportMetadata();
        Reports.ReportFormat reportFormat = reportMetadata.getReportFormat();

        Test.startTest();
            ReportSenderController.getReport(reportSender.Id);
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations);
        System.assertEquals('SUMMARY', String.valueOf(reportFormat));
    }

    @isTest(SeeAllData = 'true')
    static void testSendTabularReport() {
        ReportSender__c reportSender = new ReportSender__c (
            Report_Name__c = 'EnglishSkill',
            Cron__c = '0 58 11 * * ? *',
            Email__c = 'test@gmail.com'
        );

        insert reportSender;

        List<Report> reportList = [
            SELECT Id, Name
            FROM Report
            WHERE Name = :reportSender.Report_Name__c
        ];

        String reportId = (String)reportList.get(0).get('Id');

        Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
        Reports.ReportMetadata reportMetadata = results.getReportMetadata();
        Reports.ReportFormat reportFormat = reportMetadata.getReportFormat();

        Test.startTest();
            ReportSenderController.getReport(reportSender.Id);
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations);
        System.assertEquals('TABULAR', String.valueOf(reportFormat));
    }

    @isTest(SeeAllData = 'true')
    static void testSendMatrixReport() {
        ReportSender__c reportSender = new ReportSender__c (
            Report_Name__c = 'AccountReportTest',
            Cron__c = '0 58 11 * * ? *',
            Email__c = 'test@gmail.com'
        );

        insert reportSender;

        List<Report> reportList = [
            SELECT Id, Name
            FROM Report
            WHERE Name = :reportSender.Report_Name__c
        ];

        String reportId = (String)reportList.get(0).get('Id');

        Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
        Reports.ReportMetadata reportMetadata = results.getReportMetadata();
        Reports.ReportFormat reportFormat = reportMetadata.getReportFormat();

        Test.startTest();
            ReportSenderController.getReport(reportSender.Id);
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations);
        System.assertEquals('MATRIX', String.valueOf(reportFormat));
    }

    @isTest
    static void testCheckNotExistReport() {
        ReportSender__c reportSender = new ReportSender__c (
            Report_Name__c = 'Test',
            Cron__c = '0 58 11 * * ? *',
            Email__c = 'test@gmail.com'
        );

        insert reportSender;

        Test.startTest();
            try {
                ReportSenderController.getReport(reportSender.Id);
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e.getMessage());
            }
        Test.stopTest();

    }

    @isTest
    static void testIncorrectIdReport() {

        Test.startTest();
            try {
                ReportSenderController.getReport(null);
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e.getMessage());
            }
        Test.stopTest();

    }
}