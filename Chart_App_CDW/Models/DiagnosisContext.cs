using Chart_App_CDW.Models;
using Microsoft.EntityFrameworkCore;
using System.Diagnostics.CodeAnalysis;

namespace TodoApi.Models
{
    public class DiagnosisContext : DbContext
    {
        public DiagnosisContext(DbContextOptions<DiagnosisContext> options)
            : base(options)
        {
        }

    }
}