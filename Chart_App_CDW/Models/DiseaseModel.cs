namespace Chart_App_CDW.Models
{
    public class StatsModel
    {
        public List<int> data { get; set; } = new List<int>();
        public List<string> label { get; set; } = new List<string>();
    }

    public class DiseaseStatsModel
    {
        public string disease { get; set; }
        public StatsModel stats { get; set; }
    }
}
