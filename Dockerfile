# Use the official .NET SDK image as the base image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Set the working directory in the container
WORKDIR /app

# Copy the project files to the container
COPY . .

WORKDIR /app/src
# Restore dependencies and build the application
RUN dotnet restore
RUN dotnet build -c Release -o out

# Build the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime

# Set the working directory in the runtime image
WORKDIR /app
RUN apt-get update && \
  apt-get install wget -y

RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
 dpkg -i packages-microsoft-prod.deb && \
  rm packages-microsoft-prod.deb
#run the packages
RUN apt-get update && \
  apt-get install -y dotnet-sdk-8.0
# Copy the compiled application from the build image
COPY --from=build /app/src/out ./

# Expose the port that the application will run on
EXPOSE 80

# Start the application
ENTRYPOINT ["dotnet", "dotnet-demoapp.dll"]
