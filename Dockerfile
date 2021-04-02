FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build

# See for all possible platforms
# https://github.com/containerd/containerd/blob/master/platforms/platforms.go#L17
ARG TARGETARCH

ARG VERSIONSUFFIX="docker"

WORKDIR /source

# Copy csproj and restore.
COPY src/Impostor.Server/Impostor.Server.csproj ./src/Impostor.Server/Impostor.Server.csproj
COPY src/Impostor.Api/Impostor.Api.csproj ./src/Impostor.Api/Impostor.Api.csproj
COPY src/Impostor.Hazel/Impostor.Hazel.csproj ./src/Impostor.Hazel/Impostor.Hazel.csproj

RUN dotnet restore -r "linux-x64" ./src/Impostor.Server/Impostor.Server.csproj && \
  dotnet restore -r "linux-x64" ./src/Impostor.Api/Impostor.Api.csproj && \
  dotnet restore -r "linux-x64" ./src/Impostor.Hazel/Impostor.Hazel.csproj

# Copy everything else.
COPY src/. ./src/
RUN dotnet publish -c release -o /app -r "linux-x64" --no-restore ./src/Impostor.Server/Impostor.Server.csproj

# Final image.
FROM mcr.microsoft.com/dotnet/runtime:5.0
WORKDIR /app
COPY --from=build /app ./
EXPOSE 22023/udp
ENTRYPOINT ["./Impostor.Server"]
