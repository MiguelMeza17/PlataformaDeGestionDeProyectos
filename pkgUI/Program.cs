// 🌟 ASEGÚRATE DE QUE ESTAS LÍNEAS ESTÉN AL INICIO DE TU PROGRAM.CS
using System;
using System.IO;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders;
using Microsoft.AspNetCore.Http;
using GestionDeProyectos.pkgDomain;
using GestionDeProyectos.pkgUI;
using Oracle.ManagedDataAccess.Types;
// ... (Todo el resto de tu código de WebApplication, app.MapPost, etc. se mantiene igual)
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

// ==========================================
// ENDPOINTS DE AUTENTICACIÓN Y USUARIOS
// ==========================================

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

        if (!Enum.TryParse(datos.rol, out clsRoles rolEnum))
        {
            return Results.BadRequest(new { mensaje = "El rol proporcionado no es válido." });
        }

        bool exito = controlador.opRegisterStakeholder(
            datos.nombre, 
            "Registro desde Web", 
            datos.email, 
            datos.password, 
            rolEnum 
        );

        if (exito) {
            return Results.Ok(new { mensaje = "Usuario guardado con éxito" });
        } else {
            return Results.BadRequest(new { mensaje = "El usuario ya existe o hubo un error" });
        }
    }
    catch (Exception ex) 
    {
        return Results.Problem("Error interno: " + ex.Message);
    }
});

// ==============================================================================
// 🌟 NUEVO: ENDPOINTS PARA EL CRUD DE PROYECTOS (LLAMANDO A PKG_PROYECTO DESDE ORACLE)
// ==============================================================================

app.MapGet("/api/proyectos/listar", () => {
    try
    {
        var vrmController = clsController.opGetInstance();
        var vrmListaProyectos = vrmController.opListAllProjects();
        return Results.Ok(vrmListaProyectos);
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al listar proyectos: " + ex.Message);
    }
});

app.MapPost("/api/proyectos/crear", (clsCrearProyectoDTO prmDatos) => {
    try
    {
        var vrmController = clsController.opGetInstance();
        bool vrmExito = vrmController.opRegisterProject(
            0, 
            prmDatos.nombre,
            prmDatos.descripcion,
            prmDatos.fechaInicio,
            prmDatos.fechaFinalizacion,
            prmDatos.estadoGeneral,
            prmDatos.porcentajeAvance
        );

        if (vrmExito)
            return Results.Ok(new { mensaje = "✅ Proyecto registrado exitosamente en Oracle." });
        else
            return Results.BadRequest(new { mensaje = "❌ Error al registrar el proyecto. Verifique duplicados." });
    }
    catch (Exception ex)
    {
        return Results.Problem("Error interno al crear proyecto: " + ex.Message);
    }
});

app.MapPut("/api/proyectos/actualizar", (clsActualizarProyectoDTO prmDatos) => {
    try
    {
        var vrmController = clsController.opGetInstance();
        bool vrmExito = vrmController.opUpdateProject(
            prmDatos.idProyecto,
            prmDatos.nombre,
            prmDatos.descripcion,
            prmDatos.fechaInicio,
            prmDatos.fechaFinalizacion,
            prmDatos.estadoGeneral,
            prmDatos.porcentajeAvance
        );

        if (vrmExito)
            return Results.Ok(new { mensaje = "✅ Proyecto actualizado correctamente en Oracle." });
        else
            return Results.BadRequest(new { mensaje = "❌ No se pudo actualizar el proyecto. Verifique el ID." });
    }
    catch (Exception ex)
    {
        return Results.Problem("Error interno al actualizar proyecto: " + ex.Message);
    }
});

app.MapDelete("/api/proyectos/eliminar/{id:int}", (int id) => {
    try
    {
        var vrmController = clsController.opGetInstance();
        bool vrmExito = vrmController.opDeleteProject(id);

        if (vrmExito)
            return Results.Ok(new { mensaje = "✅ Proyecto eliminado correctamente de Oracle." });
        else
            return Results.BadRequest(new { mensaje = "❌ No se pudo eliminar el proyecto." });
    }
    catch (Exception ex)
    {
        return Results.Problem("Error interno al eliminar proyecto: " + ex.Message);
    }
});
// ==============================================================================
// 🌟 NUEVO: ENDPOINTS PARA REPORTES ANALÍTICOS (PL/SQL VIA DBMS_OUTPUT)
// ==============================================================================

app.MapGet("/api/reportes/listar", () => {
    try
    {
        var vrmController = clsController.opGetInstance();
        var vrmDatos = vrmController.opGetReporteListarProyectos();
        return Results.Ok(vrmDatos);
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al generar reporte de listado: " + ex.Message);
    }
});

app.MapGet("/api/reportes/conteo", () => {
    try
    {
        var vrmController = clsController.opGetInstance();
        var vrmDatos = vrmController.opGetReporteConteoReportes();
        return Results.Ok(vrmDatos);
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al generar reporte de conteo: " + ex.Message);
    }
});

app.MapGet("/api/reportes/promedio", () => {
    try
    {
        var vrmController = clsController.opGetInstance();
        var vrmDatos = vrmController.opGetReportePromedioAvance();
        return Results.Ok(vrmDatos);
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al generar reporte de promedios: " + ex.Message);
    }
});
app.MapPost("/api/reportes/crear", (clsCrearReporteDTO prmDatos) =>
{
    try
    {
        var vrmController = clsController.opGetInstance();

        bool vrmExito = vrmController.opRegisterReport(
    prmDatos.idProyecto,
    0,
    prmDatos.nombre,
    prmDatos.descripcion,
    prmDatos.fecha,
    prmDatos.resumenAvance,
    prmDatos.tareasRetrasadas
        );

        if (vrmExito)
        {
            return Results.Ok(new
            {
                mensaje = "Reporte registrado correctamente."
            });
        }

        return Results.BadRequest(new
        {
            mensaje = "No fue posible registrar el reporte."
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(
            "Error al registrar reporte: " + ex.Message
        );
    }
});
// ==========================================
// ARRANQUE DEL SERVIDOR
// ==========================================

Console.WriteLine("Servidor iniciado en http://localhost:5000");
app.Run("http://localhost:5000");

// ==========================================
// OBJETOS DE TRANSFERENCIA DE DATOS (DTOs)
// ==========================================
public record clsCrearReporteDTO(
    int idProyecto,
    string nombre,
    string descripcion,
    DateTime fecha,
    string resumenAvance,
    int tareasRetrasadas
);
public record LoginDTO(string nombre, string password);
public record UsuarioRegistroDTO(string nombre, string email, string password, string rol);

// DTOs para Proyectos
public record clsCrearProyectoDTO(string nombre, string descripcion, DateTime fechaInicio, DateTime fechaFinalizacion, string estadoGeneral, float porcentajeAvance);
public record clsActualizarProyectoDTO(int idProyecto, string nombre, string descripcion, DateTime fechaInicio, DateTime fechaFinalizacion, string estadoGeneral, float porcentajeAvance);


//opcional
// DTOs necesarios para mapear las entradas JSON del Administrador
