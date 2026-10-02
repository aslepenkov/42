var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddCors(options => options.AddDefaultPolicy(policy =>
    policy.WithOrigins(builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [])
          .AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();

app.UseCors();
app.UseSwagger();
app.UseSwaggerUI();

app.MapGet("/health", () => new HealthResponse("ok", DateTimeOffset.UtcNow))
   .WithName("Health");

app.MapGet("/api/hello", (string? name) => new HelloResponse($"Hello, {name ?? "world"}!"))
   .WithName("Hello");

app.Run();

record HealthResponse(string Status, DateTimeOffset Time);
record HelloResponse(string Message);
