# Prompt user for basic parameters
$resourceGroupName = Read-Host "Enter the Resource Group Name"
$location = Read-Host "Enter the Azure Location (e.g., eastus, westeurope)"
$loadBalancerName = Read-Host "Enter the Load Balancer Name"
$backendPoolName = Read-Host "Enter the Backend Pool Name"
$frontendIPName = Read-Host "Enter the Frontend IP Configuration Name"
$publicIPAddressName = Read-Host "Enter the Public IP Address Name"
$lbRuleName = Read-Host "Enter the Load Balancer Rule Name"
$protocol = Read-Host "Enter the Protocol (TCP/UDP)"
$frontendPort = Read-Host "Enter the Frontend Port (e.g., 80)"
$backendPort = Read-Host "Enter the Backend Port (e.g., 80)"

# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a Public IP Address
$publicIP = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName `
                                  -Location $location `
                                  -Name $publicIPAddressName `
                                  -Sku Standard `
                                  -AllocationMethod Static

# Create the Load Balancer with frontend IP and backend pool
$frontendIPConfig = New-AzLoadBalancerFrontendIpConfig -Name $frontendIPName `
                                                       -PublicIpAddress $publicIP

$backendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $backendPoolName

# Define Probe Configuration
$probe = New-AzLoadBalancerProbeConfig -Name "${lbRuleName}-probe" `
                                       -Protocol $protocol `
                                       -Port $backendPort `
                                       -IntervalInSeconds 5 `
                                       -ProbeCount 2

# Define Load Balancing Rule Configuration
$loadBalancingRule = New-AzLoadBalancerRuleConfig -Name $lbRuleName `
                                                  -FrontendIpConfiguration $frontendIPConfig `
                                                  -BackendAddressPool $backendAddressPool `
                                                  -Probe $probe `
                                                  -Protocol $protocol `
                                                  -FrontendPort $frontendPort `
                                                  -BackendPort $backendPort `
                                                  -IdleTimeoutInMinutes 4
# Optional: If EnableFloatingIP is required, uncomment the following and re-add it in the rule
# $enableFloatingIP = $false
# -EnableFloatingIP $enableFloatingIP

# Create Load Balancer and add configurations
$loadBalancer = New-AzLoadBalancer -ResourceGroupName $resourceGroupName `
                                   -Location $location `
                                   -Name $loadBalancerName `
                                   -FrontendIpConfiguration $frontendIPConfig `
                                   -BackendAddressPool $backendAddressPool `
                                   -Probe $probe `
                                   -LoadBalancingRule $loadBalancingRule

Write-Output "Load Balancer $loadBalancerName with frontend IP, backend pool, and rules configured successfully."
