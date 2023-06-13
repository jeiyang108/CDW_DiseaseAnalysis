
var ctx = document.getElementById("mainChart");
var myChart = new Chart(ctx, {
    type: 'bar',
    data: {},
    options: {
        indexAxis: 'y',
        scaleShowValues: true,
        scales: {
            xAxes: [{
            ticks: {
                autoSkip: false
            }
            }]
        }
    }
});

function build_graph(src) {
    var possible_colors = ["#aabbcc", "#9084bd", "#aaddcc", "#bd84a3", "#aaffcc", "#bda584"]
    labels = src.label
    darr = src.data

    var all_labels = src.map(function(e) {
        return e.stats.label
    });

    all_labels = [...new Set(all_labels.flat(1))];

    console.log(all_labels)

    datasets = src.map(function(e, i) {
        return {
            axis: 'y',
            backgroundColor: possible_colors[i % possible_colors.length],
            label: 'Patients per BMI Range (' + e.disease + ')',
            data: all_labels.map(function(src_lbl) {
                let lookup_idx = e.stats.label.indexOf(src_lbl);
                
                if(lookup_idx < 0)
                    return 0;
                
                return e.stats.data[lookup_idx]
            }),
            fill: false,
            borderWidth: 1
        }
    })

    const data = {
        labels: all_labels,
        datasets: datasets
    };

    var table_data = src.map(function(e, x) {
        return e.stats.label.map(function(ee, i) {
            return {
                id: x* 1000 + i,
                disease: e.disease,
                bmi_range: ee,
                patients: e.stats.data[i] //.stat.data[i]
            }
        });
    });

    table_data = table_data.flat(1);
    
    myChart.data = data;
    myChart.update();
    mainTable.setData(table_data);

}

function print_chart(areaID) {

    var printContent = document.getElementById(areaID).innerHTML;
    var originalContent = document.body.innerHTML;
    document.body.innerHTML = printContent;
    window.print();
    document.body.innerHTML = originalContent;
}

function print_report()
{
    printDiv = "#chartBlock"; // id of the div you want to print
    $("*").addClass("no-print");

    $(printDiv+" *").removeClass("no-print");
    $(printDiv).removeClass("no-print");

    parent =  $(printDiv).parent();
    //parent += $(printDiv2).parent();
    while($(parent).length)
    {
        $(parent).removeClass("no-print");
        parent =  $(parent).parent();
    }
    window.print();

}