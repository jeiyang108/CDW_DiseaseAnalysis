using Chart_App_CDW.Models;
using Microsoft.EntityFrameworkCore;
using TodoApi.Models;

using System.Data;
using System.Data.Odbc;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
//builder.Services.AddDbContext<DiagnosisContext>(opt =>
    //opt.UseInMemoryDatabase("COMP8071_Project"));// DiagnosisFactsModel

builder.Services.AddDbContext<DiagnosisContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DiagnosisContext")));
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer(); //tbd
//builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    //app.UseSwagger();
    //app.UseSwaggerUI();
}

app.UseDefaultFiles();
app.UseStaticFiles();
app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
