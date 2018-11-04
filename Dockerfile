FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
COPY "bookystuff.Server/bookystuff.Server.csproj", "bookystuff.Server/"
COPY "bookystuff.Client/bookystuff.Client.csproj", "bookystuff.Client/"
COPY "bookystuff.Shared/bookystuff.Shared.csproj", "bookystuff.Shared/"
RUN dotnet restore "bookystuff.Server/bookystuff.Server.csproj"
COPY . .
WORKDIR /src/bookystuff.Server
RUN dotnet build bookystuff.Server.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish "bookystuff.Server.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "bookystuff.Server.dll"]