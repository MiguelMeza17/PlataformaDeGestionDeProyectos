using System;
using System.IO; // <-- Agregado para poder manejar rutas de archivos
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders; // <-- Agregado para el mapeo de carpetas
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

// ==========================================
// 🚨 CORRECCIÓN 1: ACTIVAR TUS ARCHIVOS HTML/CSS/JS
// ==========================================
// Obtenemos la ruta real de tu proyecto en la computadora
string proyectoRaiz = Directory.GetCurrentDirectory(); 
string rutaPkgUI = Path.Combine(proyectoRaiz, "pkgUI");

// Le decimos a .NET que exponga públicamente la carpeta pkgUI
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(rutaPkgUI),
    RequestPath = "/pkgUI" 
});
// ==========================================

app.MapPost("/api/registrar", (UsuarioRegistroDTO datos) => {
    try 
    {
        var controlador = clsController.opGetInstance();

        if (!Enum.TryParse(datos.rol, true, out clsRoles rolEnum))
        {
            return Results.BadRequest(new { mensaje = "El rol proporcionado no existe en el sistema." });
        }

        bool exito = controlador.opRegisterStakeholder(
            datos.id, 
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

app.MapPost("/api/login", (LoginDTO datos) => {
    try 
    {
        var controlador = clsController.opGetInstance();
        var usuario = controlador.opLoginStakeholder(datos.nombre, datos.password);

        if (usuario != null) {
            // ==========================================
            // 🚨 CORRECCIÓN 2: ENVIAR EL USUARIO CON SU ROL EN EL JSON
            // ==========================================
            // Retornamos tanto el mensaje como el objeto usuario (que contiene .rol o .nombre)
            return Results.Ok(usuario); 
        }
        return Results.Json(new { mensaje = "Usuario o contraseña incorrectos" }, statusCode: 401);
    }
    catch (Exception ex) 
    {
        return Results.Problem("Error interno en el login: " + ex.Message);
    }
});

Console.WriteLine("Servidor iniciado en http://localhost:5000");
app.Run("http://localhost:5000");

public record UsuarioRegistroDTO(string id, string nombre, string email, string password, string rol);
public record LoginDTO(string nombre, string password);