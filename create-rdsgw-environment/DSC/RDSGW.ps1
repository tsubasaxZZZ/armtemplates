Configuration RemoteDesktopSessionHost
{
    param
    (

        # Connection Broker Name
        [String]$collectionName="Collection",

        # Connection Broker Description
        [String]$collectionDescription="Default Collection",

        # Connection Broker Node Name
        [String]$connectionBroker,

        # Web Access Node Name
        [String]$webAccessServer
    )
    $localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName
    Import-DscResource -ModuleName xRemoteDesktopSessionHost

    if (!$connectionBroker) {$connectionBroker = $localhost}
    if (!$connectionWebAccessServer) {$webAccessServer = $localhost}

    Node "localhost"
    {

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature Remote-Desktop-Services
        {
            Ensure = "Present"
            Name = "Remote-Desktop-Services"
        }

        WindowsFeature RDS-RD-Server
        {
            Ensure = "Present"
            Name = "RDS-RD-Server"
        }

        WindowsFeature RDS-Gateway
        {
            Ensure = "Present"
            Name = "RDS-Gateway"
        }
        WindowsFeature RSAT-RDS-Tools
        {
            Ensure = "Present"
            Name = "RSAT-RDS-Tools"
            IncludeAllSubFeature = $true
        }

        if ($localhost -eq $connectionBroker) {
            WindowsFeature RDS-Connection-Broker
            {
                Ensure = "Present"
                Name = "RDS-Connection-Broker"
            }
        }

        if ($localhost -eq $webAccessServer) {
            WindowsFeature RDS-Web-Access
            {
                Ensure = "Present"
                Name = "RDS-Web-Access"
            }
        }

        WindowsFeature RDS-Licensing
        {
            Ensure = "Present"
            Name = "RDS-Licensing"
        }

        xRDSessionDeployment Deployment
        {
            SessionHost = $localhost
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            WebAccessServer = if ($WebAccessServer) {$WebAccessServer} else {$localhost}
            DependsOn = "[WindowsFeature]Remote-Desktop-Services", "[WindowsFeature]RDS-RD-Server"
        }

        xRDSessionCollection Collection
        {
            CollectionName = $collectionName
            CollectionDescription = $collectionDescription
            SessionHost = $localhost
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            DependsOn = "[xRDSessionDeployment]Deployment"
        }
        xRDSessionCollectionConfiguration CollectionConfiguration
        {
            CollectionName = $collectionName
            CollectionDescription = $collectionDescription
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            TemporaryFoldersDeletedOnExit = $false
            SecurityLayer = "SSL"
            DependsOn = "[xRDSessionCollection]Collection"
        }
        xRDGatewayConfiguration GatewayConfiguration
        {
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            GatewayServer = $localhost
            GatewayMode = "Custom"
            ExternalFqdn = "RDSGW.corp.contoso.com"
            LogonMethod = "Password"
            UseCachedCredentials = $true
            BypassLocal = $true
            DependsOn = "[xRDSessionCollectionConfiguration]CollectionConfiguration"
        }

    }
}
RemoteDesktopSessionHost