# Etap 1: Base - obraz uruchomieniowy
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Etap 2: Build - obraz SDK do kompilacji
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Kopiujemy csproj i przywracamy zależności (dla lepszego cache'owania warstw)
COPY ["BiteHack.Web/BiteHack.Web.csproj", "BiteHack.Web/"]
RUN dotnet restore "./BiteHack.Web/BiteHack.Web.csproj"

# Kopiujemy resztę plików kodu źródłowego
COPY . .
WORKDIR "/src/BiteHack.Web"
RUN dotnet build "./BiteHack.Web.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Etap 3: Publish - przygotowanie plików do wdrożenia
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./BiteHack.Web.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Etap 4: Final - ostateczny obraz
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BiteHack.Web.dll"]