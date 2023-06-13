$('service_picker').selectpicker();

var report_name = "/api/diagnosis"

var mainTable = new Tabulator("#mainTable", {
    columns:[
        {title:"Disease", field: "disease"},
        {title:"BMI Range", field: "bmi_range"},
        {title:"# of Patients", field: "patients"}
    ],
});

function reload_orchestrate() {
    var report_filters = "?"
    var report_endpoint =report_name
    var selected_services = $('#disease_select').val();

    if(selected_services != "")
        report_filters += "&disease_id=" + selected_services

    $.getJSON(report_endpoint + report_filters, function(data) {
        build_graph(data);
    });
}

function load_orchestrate() {
    var report_endpoint = report_name

    $.getJSON("/api/disease", function(data) {
        for (const x of data) {
            $('#disease_select').append('<option value="' + x.diseaseID + '">' + x.disease + '</option>');
        }

        $('#disease_select').val(-1);
        $('#disease_select').selectpicker('refresh');

        $('#disease_select').on('change', function() {
            reload_orchestrate();
         });
    });

    $.getJSON(report_endpoint, function(data) {
        build_graph(data);
    });
}

