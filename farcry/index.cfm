<cfsetting requesttimeout="10000" />

<!--- 
TODO
	- check database type
	- build refObjects
	- redirect to webtop
 --->

<!--- 
 // environment variables 
--------------------------------------------------------------------------------->
<!--- get project directory; assumes only one project --->
<cfdirectory action="list" directory="#expandPath('/farcry/projects')#" name="qProjects" type="dir" />

<!--- get farcryConstructor.cfm settings --->
<cffile action="read" file="#qProjects.directory#/#qProjects.name#/www/farcryConstructor.cfm" variable="farcryConstructor" />
<cfset stInstall = structNew()>
<cfset stInstall.name = rereplacenocase(farcryConstructor,'.*<cfset\s*?THIS.Name\s*?=\s*?["''](.*?)["''].*', '\1' , 'all') />
<cfset stInstall.dsn = rereplacenocase(farcryConstructor,'.*<cfset\s*?THIS.dsn\s*?=\s*?["''](.*?)["''].*', '\1' , 'all') />
<cfset stInstall.dbType = rereplacenocase(farcryConstructor,'.*<cfset\s*?THIS.dbType\s*?=\s*?["''](.*?)["''].*', '\1' , 'all') />
<cfset stInstall.dbOwner = rereplacenocase(farcryConstructor,'.*<cfset\s*?THIS.dbOwner\s*?=\s*?["''](.*?)["''].*', '\1' , 'all') />

<!--- check the datasource; must be empty --->
<cfset stCheckDSN = checkDSN(dsn="#stInstall.dsn#", dbOwner="#stInstall.dbOwner#") />


<!--- 
 // process form 
--------------------------------------------------------------------------------->
<!--- insert data; deploy tables, run inserts --->
<cfif structKeyExists(form, "installAction") AND form.installAction EQ "Install">
	
	<cfset sqlDirectory = "#qProjects.directory#/#qProjects.name#/install">
	
	<!--- DEPLOY database schema --->
	<cfset sqlFilePrefix = "DEPLOY-#form.dbType#_">
	<cfdirectory action="list" directory="#sqlDirectory#" name="qSQLFiles" filter="#sqlFilePrefix#*.sql" />
	
	<cfif qSQLFiles.recordCount>
		
		<cfloop query="qSQLFiles">
			<cffile action="read"  file="#sqlDirectory#/#qSQLFiles.NAME#" variable="SQL">
			
			<cftry>
				<cfquery datasource="#form.dsn#" name="qInsert">
				#PreserveSingleQuotes(SQL)#
				</cfquery>
			
			<cfcatch type="any">
				<cfdump var="#cfcatch#"><cfabort>

			</cfcatch>
			</cftry>
			<cfoutput><div>DONE - #sqlDirectory#/#qSQLFiles.NAME#</cfoutput><cfflush>
		</cfloop>
		
	</cfif>
	
	<!--- INSERT project sample data --->
	<cfset sqlFilePrefix = "INSERT-">
	<cfdirectory action="list" directory="#sqlDirectory#" name="qSQLFiles" filter="#sqlFilePrefix#*.sql" />
	

	<cfif qSQLFiles.recordCount>
		
		<cfloop query="qSQLFiles">
			<cffile action="read"  file="#sqlDirectory#/#qSQLFiles.NAME#" variable="SQL">
			
			<cftry>
				<cfquery datasource="#form.dsn#" name="qInsert">
				#PreserveSingleQuotes(SQL)#
				</cfquery>
	
			
			<cfcatch type="any">
				<cfdump var="#cfcatch#"><cfabort>
			</cfcatch>
			</cftry>
			
			<cfoutput><div>DONE - #sqlDirectory#/#qSQLFiles.NAME#</cfoutput><cfflush>
		</cfloop>
		
		
	</cfif>
	 
	<!--- Update the farcry password --->
	<cfquery datasource="#form.dsn#">
		update		#form.dbowner#farUser
		set			password=<cfqueryparam cfsqltype="cf_sql_varchar" value="farcry" />
		where		userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="farcry" />
	</cfquery>

	<cflocation url="#cgi.script_name#" />
</cfif>


<!--- 
 // view 
--------------------------------------------------------------------------------->
<cfoutput>
<!DOCTYPE html>
<html>
  <head>
    <title>FarCry: CloudBees Chelsea Install</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/css/bootstrap-combined.no-icons.min.css" rel="stylesheet">
	<link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet">
  </head>
  <body>
  	<div class="span3"></div>
  	<div class="span6">
    <h1>CloudBees Chelsea Install</h1>
    
	<cfif NOT stCheckDSN.bSuccess>
		<div class="alert alert-block">
			<h4>#stCheckDSN.errorTitle#</h4>
			#stCheckDSN.errorDescription#
		</div>
	<cfelse>
		<form class="form-horizontal" action="#cgi.script_name#?#cgi.query_string#" enctype="multipart/form-data" method="post">
			<input type="hidden" name="dbtype" value="#stInstall.dbtype#">
			<input type="hidden" name="dsn" value="#stInstall.dsn#">
			<input type="hidden" name="dbowner" value="#stInstall.dbowner#">

			<h3>Install Database</h3>
			<div class="control-group">
				<label class="control-label" for="farcryUserPassword">Farcry User Password</label>
				<div class="controls">
					<input type="text" name="farcryUserPassword" placeholder="" value="farcry">
				</div>
			</div>

			<div class="control-group">
				<div class="controls">
				<cfif stCheckDSN.bSuccess>
					<button type="submit" name="installAction" value="Install" class="btn btn-large btn-primary">Install Chelsea Boots</button>
				</cfif>
				</div>
			</div>
		</form>
	</cfif>

    <h3>farcryConstructor.cfm Settings</h3>
	<div class="alert alert-info">
		Constructor is located at <code>#qProjects.directory#/#qProjects.name#/www/farcryConstructor.cfm</code>
	</div>
    
	<dl>
		<dt>application.name = #stInstall.name#</dt>
		<dd>Project Name; you can modify the name of the project by updating the <code>&lt;cfset THIS.Name = "#stInstall.name#" /&gt;</code> variable in the constructor.</dd>

		<dt>application.dbtype = #stInstall.dbtype#</dt>
		<dd>Database type; you can modify the database type of the project by updating the <code>&lt;cfset THIS.dbtype = "#stInstall.dbtype#" /&gt;</code> variable in the constructor.</dd>
		<dd>Your best option for CloudBees installation is the CloudBees mySQL database instance.</dd>

		<dt>application.dbowner = #stInstall.dbowner#</dt>
		<dd>Project Name; you can modify the name of the project by updating the <code>&lt;cfset THIS.dbowner = "#stInstall.dbowner#" /&gt;</code> variable in the constructor.</dd>

		<dt>application.dsn = #stInstall.dsn#</dt>
		<dd>Project Name; you can modify the name of the project by updating the <code>&lt;cfset THIS.dsn = "#stInstall.dsn#" /&gt;</code> variable in the constructor.</dd>
	</dl>

	</div>
  	<div class="span3"></div>
  	

    <script src="http://code.jquery.com/jquery.js"></script>
  </body>
</html>
	
</cfoutput>










<!--- 
 // UDF Library 
--------------------------------------------------------------------------------->
	<cffunction name="checkDSN" access="public" returntype="struct" output="false" hint="Check to see whether the DSN entered by the user is valid">
		<cfargument name="DSN" type="string" required="true" hint="DSN to check" />
		<cfargument name="DBOwner" type="string" required="true" hint="The database owner" />

		<cfset var qCheckDSN = queryNew("blah") />
		<cfset var stResult = structNew() />
		<cfset stResult.bSuccess = true />
		<cfset stResult.errorTitle = "" />
		<cfset stResult.errorDescription = "" />
		

		<cftry>
			<!--- run any query to see if the DSN is valid --->
			<cfquery name="qCheckDSN" datasource="#arguments.dsn#">
				SELECT 'patrick' AS theMAN
			</cfquery>
			
			<cfcatch type="database">
				<cftry>						
					<!--- First check for oracle will fail. This is the oracle check.
					Run any query to see if the DSN is valid --->
					<cfquery name="qCheckDSN" datasource="#arguments.dsn#">
						SELECT 'patrick' AS theMAN from dual
					</cfquery>
					
					<cfcatch type="database">
						<cftry>
							<!--- Both checks for HSQLDB will fail. see if this might an HSQLDB --->
							<cfquery name="qCheckDSN" datasource="#arguments.dsn#">
								SET READONLY FALSE;
							</cfquery>
							
							<cfcatch type="database">
								<cfset stResult.bSuccess = false />
								<cfset stResult.errorTitle = "Invalid Datasource (DSN)" />
								<cfsavecontent variable="stResult.errorDescription">
									<cfoutput>
									<p>Your DSN (#arguments.dsn#) is invalid.</p>
									<p>Please check it is setup and verifies within the ColdFusion Administrator.</p>
									</cfoutput>
								</cfsavecontent>
							</cfcatch>
						</cftry>
					</cfcatch>
					
				</cftry>
			</cfcatch>
			
		</cftry>
		
		<cfif stResult.bSuccess>
			<cfset stResult = checkExistingDatabase(dbOwner="#arguments.dbOwner#",dsn="#arguments.dsn#") />
		</cfif>
		
		<cfreturn stResult />
	
	</cffunction>
	
	
	
	<cffunction name="checkExistingDatabase" access="public" returntype="struct" output="false" hint="Check to see whether a farcry database exists">
		<cfargument name="DSN" type="string" required="true" hint="DSN to check" />
		<cfargument name="DBOwner" type="string" required="true" hint="The database owner" />

		<cfset var qCheckDSN = queryNew("blah") />
		<cfset var bExists = true />
		<cfset var stResult = structNew() />
		<cfset stResult.bSuccess = true />
		<cfset stResult.errorTitle = "" />
		<cfset stResult.errorDescription = "" />

		<cftry>
		
			<!--- run any query to see if there is an existing farcry project in the database --->
			<cfquery name="qCheckDSN" datasource="#arguments.dsn#">
				SELECT	count(objectId) AS theCount
				FROM	#arguments.DBOwner#refObjects
			</cfquery>
			
			<cfcatch type="database">
				<cfset bExists = false />
			</cfcatch>
			
		</cftry>
		
		<cfif bExists>
			
			<cfset stResult.bSuccess = false />
			<cfset stResult.errorTitle = "Existing Farcry Database Found" />
			<cfsavecontent variable="stResult.errorDescription">
				<cfoutput>
				<p>Your database contains an existing Farcry application.</p>
				<p>You can only install into an empty database.</p>
				</cfoutput>			
			</cfsavecontent>
		
		</cfif>		
		
		<cfreturn stResult />
	
	</cffunction>	
	

	
	<cffunction name="checkDBType" access="public" returntype="struct" output="false" hint="Check to see whether the database is Oracle">
		<cfargument name="DSN" type="string" required="true" hint="DSN to check" />
		<cfargument name="DBType" type="string" required="true" hint="Type of DB to check" />
		<cfargument name="DBOwner" type="string" required="true" hint="The database owner" />

		<cfset var qCheckDSN = queryNew("blah") />
		<cfset var bCorrectDB = true />
		<cfset var databaseTypeName = "" />
		<cfset var stResult = structNew() />
		<cfset stResult.bSuccess = true />
		<cfset stResult.errorTitle = "" />
		<cfset stResult.errorDescription = "" />

		<cftry>
			<cfswitch expression="#arguments.DBType#">
			<cfcase value="ora">
				<cfset databaseTypeName = "Oracle" />
				<!--- run an oracle specific query --->
				<cfquery name="qCheckDSN" datasource="#arguments.dsn#">
				SELECT 'aj' AS theMAN from dual
				</cfquery>
			</cfcase>
			<cfcase value="MSSQL,MSSQL2005" delimiters=",">
				<cfset databaseTypeName = arguments.DBType />
				<!--- run an MSSQL specific query --->
				<cfquery name="qCheckDSN" datasource="#arguments.dsn#">
				SELECT	count(*) AS theCount
				FROM	#arguments.DBOwner#sysobjects
				</cfquery>
			</cfcase>
			<cfcase value="MySQL">
				<cfset databaseTypeName = "MySQL" />						
				<!--- test temp table creation --->
				<cfquery name="qTestPrivledges" datasource="#arguments.dsn#">
					create temporary table tblTemp1
					(
					test  VARCHAR(255) NOT NULL
					)
				</cfquery>	
				<!--- delete temp table --->
				<cfquery name="qDeleteTemp" datasource="#arguments.dsn#">
					DROP TABLE IF EXISTS tblTemp1
				</cfquery>							
			</cfcase>
			<cfcase value="Postgres">
				<cfset databaseTypeName = "Postgres" />						
				<!--- TODO: perform test to validate dbtype is postgres --->									
			</cfcase>
			
			<cfcase value="HSQLDB">
				<cfset databaseTypeName = "HSQLDB" />
				<!--- TODO: perform test to validate dbtype is HSQLDB --->									
			</cfcase>
			
			</cfswitch>
			
			<cfcatch type="database">
				<cfset bCorrectDB = false />
			</cfcatch>
			
		</cftry>
		
		<cfif not bCorrectDB>
			
			<cfset stResult.bSuccess = false />
			<cfset stResult.errorTitle = "Not A #databaseTypeName# Database" />
			<cfsavecontent variable="stResult.errorDescription">
				<cfoutput>
				<p>Your database does not appear to be #databaseTypeName#.</p>
				<p>Please check the database type and try again.</p>
				<cfif arguments.DBType eq "MySQL"><p>Please check that the database user has permission to create temporary tables.</p></cfif>
				</cfoutput>			
			</cfsavecontent>
		
		</cfif>		
		
		<cfreturn stResult />
	
	</cffunction>





<!---
 Copies a directory.
 v1.0 by Joe Rinehart
 v2.0 mod by [author not noted]
 v3.1 mod by Anthony Petruzzi
 v3.2 mod by Adam Cameron under guidance of Justin Z (removing NAMECONFLICT argument which was never supported in file-copy operations)
 
 @param source      Source directory. (Required)
 @param destination      Destination directory. (Required)
 @param ignore      List of folders, files to ignore. Defaults to nothing. (Optional)
 @return Returns nothing. 
 @author Joe Rinehart (joe.rinehart@gmail.com) 
 @version 3.2, March 21, 2013 
--->
<cffunction name="dCopy" output="false" returntype="void">
    <cfargument name="source" required="true" type="string">
    <cfargument name="destination" required="true" type="string">
    <cfargument name="ignore" required="false" type="string" default="">

    <cfset var contents = "">
    
    <cfif not(directoryExists(arguments.destination))>
        <cfdirectory action="create" directory="#arguments.destination#">
    </cfif>
    
    <cfdirectory action="list" directory="#arguments.source#" name="contents">

    <cfif len(arguments.ignore)>
        <cfquery dbtype="query" name="contents">
        select * from contents where name not in(#ListQualify(arguments.ignore, "'")#)
        </cfquery>
    </cfif>
    
    <cfloop query="contents">
        <cfif contents.type eq "file">
            <cffile action="copy" source="#arguments.source#/#name#" destination="#arguments.destination#/#name#">
        <cfelseif contents.type eq "dir" AND name neq '.svn' AND name neq '.git'>
            <cfset dCopy(arguments.source & "/" & name, arguments.destination & "/" & name)>
        </cfif>
    </cfloop>
</cffunction>
