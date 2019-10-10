global class ReportSenderSch implements Schedulable {

    private String reportId;

    public ReportSenderSch (Id recordId) {
        reportId = recordId;
    }

    global void execute(SchedulableContext sc) {
        ReportSenderController.getDataReport(reportId);
    }

}