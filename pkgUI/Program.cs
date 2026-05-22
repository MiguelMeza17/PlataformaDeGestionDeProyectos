using System;
using System.IO;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders;
using Microsoft.AspNetCore.Http;
using GestionDeProyectos.pkgDomain;
using GestionDeProyectos.pkgUI;

var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    ContentRootPath = AppContext.BaseDirectory
});

builder.Services.AddCors(options => {
    options.AddDefaultPolicy(policy => {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.ConfigureHttpJsonOptions(options => {
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter());
});

var app = builder.Build();
app.UseCors();

string proyectoRaiz = Directory.GetCurrentDirectory(); 
string rutaPkgUI = Path.Combine(proyectoRaiz, "pkgUI");

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(rutaPkgUI),
    RequestPath = "/pkgUI" 
});

app.MapPost("/api/login", (LoginDTO datos) => {
    try 
    {
        var controlador = clsController.opGetInstance();
        var usuario = controlador.opLoginStakeholder(datos.nombre, datos.password);

        if (usuario != null) {
            return Results.Ok(new {
                nombre = usuario.GetNombre(),
                rolId = (int)usuario.GetRol()
            });
        }
        return Results.Json(new { mensaje = "Usuario o contraseña incorrectos" }, statusCode: 401);
    }
    catch (Exception ex) 
    {
        return Results.Problem("Error interno en el login: " + ex.Message);
    }
});

app.MapPost("/api/registrar", (UsuarioRegistroDTO datos) => {
    try 
    {
        var controlador = clsController.opGetInstance();

        if (!int.TryParse(datos.id, out int idConvertido))
        {
            return Results.BadRequest(new { mensaje = "El ID debe ser un número entero válido." });
        }

        if (!int.TryParse(datos.rol, out int rolInt))
        {
            return Results.BadRequest(new { mensaje = "El rol debe ser un número (0, 1 o 2)." });
        }

        clsRoles rolEnum = (clsRoles)rolInt;

        bool exito = controlador.opRegisterStakeholder(
            idConvertido, 
            datos.nombre, 
            "Registro desde Web", 
            datos.email, 
            datos.password, 
            rolEnum 
        );

        if (exito) {
            return Results.Ok(new { mensaje = "Usuario guardado con éxito en Oracle" });
        } else {
            return Results.BadRequest(new { mensaje = "El ID ya existe o hubo un error en la BD" });
        }
    }
    catch (Exception ex) 
    {
        return Results.Problem("Error interno: " + ex.Message);
    }
});

Console.WriteLine("Servidor iniciado en http://localhost:5000");
app.Run("http://localhost:5000");

public record LoginDTO(string nombre, string password);
public record UsuarioRegistroDTO(string id, string nombre, string email, string password, string rol);