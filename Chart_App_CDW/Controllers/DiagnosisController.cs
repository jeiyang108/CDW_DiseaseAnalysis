using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Chart_App_CDW.Models;
using TodoApi.Models;
using System.Data.Odbc;
using System.Data;
using System.Data.Common;
using NuGet.Protocol;

namespace Chart_App_CDW.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DiseaseController : ControllerBase
    {
        OdbcConnection conn = new OdbcConnection("Data Provider=SQLOLEDB;Dsn=OFFICE;Database=COMP8071_Project;");
        private readonly DiagnosisContext _context;

        public DiseaseController(DiagnosisContext context)
        {
            _context = context;
        }

        // GET: api/DiagnosisFactsModels
        [HttpGet]
        public IEnumerable<DiseaseModel> GetDiagnosis()
        //public async Task<ActionResult<IEnumerable<DiabetesBMIModel>>> GetDiagnosis()
        {

            conn.Open();
            Console.WriteLine("Database Connected");
            OdbcCommand dbCommand = conn.CreateCommand();
            dbCommand.CommandType = CommandType.Text;
            dbCommand.CommandText = @"SELECT y.DiseaseId, y.Disease from DiseaseDim y where y.DiseaseId in (select distinct n.DiseaseId from DiagnosisFacts n )";
            OdbcDataReader dbReader = dbCommand.ExecuteReader();


            List<DiseaseModel> models = new List<DiseaseModel>();

            while (dbReader.Read())
            {
                var model = new DiseaseModel();
                model.Disease = (string)dbReader.GetValue("Disease");
                model.DiseaseID = (int)dbReader.GetValue("DiseaseID");
                models.Add(model);
            }

            dbReader.Close();
            dbCommand.Dispose();
            conn.Close();

            return models;
        }

    }


    [Route("api/[controller]")]
    [ApiController]
    public class DiagnosisController : ControllerBase
    {
        OdbcConnection conn = new OdbcConnection("Data Provider=SQLOLEDB;Dsn=OFFICE;Database=COMP8071_Project;");

        private readonly DiagnosisContext _context;

        public DiagnosisController(DiagnosisContext context)
        {
            _context = context;
        }

        // GET: api/DiagnosisFactsModels
        [HttpGet]
        public List<DiseaseStatsModel> GetDiagnosis(string? disease_id)
        //public async Task<ActionResult<IEnumerable<DiabetesBMIModel>>> GetDiagnosis()
        {


            var diseaseFilter = disease_id != null ? disease_id.Split(",") : Enumerable.Empty<string>();

            conn.Open();
            Console.WriteLine("Database Connected");
            OdbcCommand dbCommand = conn.CreateCommand();
            dbCommand.CommandType = CommandType.Text;
            dbCommand.CommandText = @"SELECT dd.Disease, bd.BMIRange, SUM(NumOfPatients) AS 'NumOfPatients'
                                      FROM [COMP8071_Project].[dbo].[DiagnosisFacts] df
                                      JOIN BMIRangeDim bd ON df.BMIRangeID = bd.BMIRangeID
                                      JOIN DiseaseDim dd ON df.DiseaseID = dd.DiseaseID
                                      WHERE bd.BMIRangeID IN (1,2,3,4,5) AND dd.DiseaseID IN (3,4,5, 39, 40)
                                     " + 
                                        (diseaseFilter.Any() ? ("AND df.DiseaseId in (" + String.Join(",", diseaseFilter) + ")") : "")
                                       +
                                     @"GROUP BY bd.BMIRangeID, bd.BMIRange, dd.DiseaseID, dd.Disease
                                      ORDER BY dd.DiseaseID, bd.BMIRangeID; ";
            OdbcDataReader dbReader = dbCommand.ExecuteReader();

            var stats = new Dictionary<string, DiseaseStatsModel>();
            while (dbReader.Read())
            {
                var d = (string)dbReader.GetValue("Disease");

                if (!stats.ContainsKey(d))
                {
                    stats[d] = new DiseaseStatsModel();
                    stats[d].disease = d;
                    stats[d].stats = new StatsModel();
                }

                var dstats = stats[d];

                dstats.stats.label.Add((string)dbReader.GetValue("BMIRange"));
                dstats.stats.data.Add((int)dbReader.GetValue("NumOfPatients"));
            }

            dbReader.Close();
            dbCommand.Dispose();
            conn.Close();
            //ViewBag.data = data;
            return stats.Values.ToList();
            //return await _context.Diagnosis.ToListAsync();
        }


    }
}
