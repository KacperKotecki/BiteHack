# --- Stage 1: Build & Publish ---
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# 1. Kopiujemy plik projektu, zachowując strukturę folderów
# Dockerfile jest w root, więc wskazujemy: "Weź plik z folderu BiteHack.Web i wrzuć go do folderu BiteHack.Web w kontenerze"
COPY ["BiteHack.Web/BiteHack.Web.csproj", "BiteHack.Web/"]

# 2. Pobieramy biblioteki (Restore) celując w ten konkretny plik
RUN dotnet restore "BiteHack.Web/BiteHack.Web.csproj"

# 3. Kopiujemy całą resztę plików z głównego katalogu (czyli folder BiteHack.Web trafi do kontenera)
COPY . .

# 4. Zmieniamy folder roboczy na ten z projektem, żeby wykonać build
WORKDIR "/src/BiteHack.Web"
RUN dotnet publish "BiteHack.Web.csproj" -c Release -o /app/publish /p:UseAppHost=false

# --- Stage 2: Runtime ---
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Kopiujemy skompilowaną aplikację z etapu 'build'
COPY --from=build /app/publish .

# Setup portów
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "BiteHack.Web.dll"]