# First some common params, delivered by the nuget package installer
param($installPath, $toolsPath, $package, $project)

# Get project path
$path = [System.IO.Path]
$projectpath = $path::GetDirectoryName($project.FileName)

# Copy content from old episerver.config -> episerver.config.config
$episerverconfig = $path::Combine($projectpath, "episerver.config")
$episerverconfigconfig = $path::Combine($projectpath, "episerver.config.config")
copy $episerverconfig $episerverconfigconfig

# Copy content from old EPiServerFramework.config -> EPiServerFramework.config.config
$episerverframeworkconfig = $path::Combine($projectpath, "EPiServerFramework.config")
$episerverframeworkconfigconfig = $path::Combine($projectpath, "EPiServerFramework.config.config")
copy $episerverframeworkconfig $episerverframeworkconfigconfig

# Copy content from old connectionStrings.config -> connectionStrings.config.config
$connectionstringsconfig = $path::Combine($projectpath, "connectionStrings.config")
$connectionstringsconfigconfig = $path::Combine($projectpath, "connectionStrings.config.config")
copy $connectionstringsconfig $connectionstringsconfigconfig

# Get the build project of type [Microsoft.Build.Evaluation.Project]
$buildProject = Get-Project $project.ProjectName | % {
            $path = $_.FullName
            @([Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.GetLoadedProjects($path))[0]
        }

# Find the Content node for "episerver.config.substitute.xml"
$episerverconfigsubstitutenode = $buildProject.Xml.ItemGroups | foreach {$_.Items} | Where-Object {$_.Include -match "episerver.config.substitute.xml"}

# Add a dependency to "episerver.config.config" for "episerver.config.substitute.xml"
$episerverconfigsubstitutenode.AddMetaData("DependentUpon", "episerver.config.config")

# Find the Content node for "EPiServerFramework.config.substitute.xml"
$episerverframeworkconfigsubstitutenode = $buildProject.Xml.ItemGroups | foreach {$_.Items} | Where-Object {$_.Include -match "EPiServerFramework.config.substitute.xml"}

# Add a dependency to "EPiServerFramework.config.config" for "EPiServerFramework.config.substitute.xml"
$episerverframeworkconfigsubstitutenode.AddMetaData("DependentUpon", "EPiServerFramework.config.config")

# Find the Content node for "connectionStrings.config.substitute.xml"
$connectionstringsconfigsubstitutenode = $buildProject.Xml.ItemGroups | foreach {$_.Items} | Where-Object {$_.Include -match "connectionStrings.config.substitute.xml"}

# Add a dependency to "connectionStrings.config.config" for "connectionStrings.config.substitute.xml"
$connectionstringsconfigsubstitutenode.AddMetaData("DependentUpon", "connectionStrings.config.config")


# Persists the changes in project
$project.Save() 
