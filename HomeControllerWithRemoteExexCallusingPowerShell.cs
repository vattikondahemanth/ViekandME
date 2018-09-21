using Hangfire;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data.SqlClient;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Security;
using System.Text;
using System.Web;
using System.Web.Mvc;
using System.Configuration;
using System.Data;
using System.ComponentModel;

namespace SBIHangFire.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return Redirect("~"); 
            
        }

        public ActionResult StartJobs()
        {
            RemoteCall();
            return View();
        }
        [AutomaticRetry(Attempts = 0)]
        public void RemoteCall()
        {

            string connetionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString.ToString();
            string query = ConfigurationManager.AppSettings["Query"].ToString();
            SqlConnection connection;
            SqlDataAdapter adapter;
            DataSet ds = new DataSet();
            int i = 0;
            connection = new SqlConnection(connetionString);
            try
            {
                connection.Open();
                adapter = new SqlDataAdapter(query, connection);
                adapter.Fill(ds);
                connection.Close();
                
                for (i = 0; i <= ds.Tables[0].Rows.Count -1 ; i++)
                {
                    bool IsActive = Convert.ToBoolean(ds.Tables[0].Rows[i]["IsActive"]);
                    if (IsActive)
                    {

                        RecurringJobManager manager = new RecurringJobManager();
                        
                        string cronExp = ds.Tables[0].Rows[i]["CronExpression"].ToString();
                        string domain = ds.Tables[0].Rows[i]["Domain"].ToString();
                        string username = ds.Tables[0].Rows[i]["UserName"].ToString();
                        string password = ds.Tables[0].Rows[i]["Password"].ToString();
                        string remoteIP = ds.Tables[0].Rows[i]["RemoteComputerIP"].ToString();
                        string jobname = ds.Tables[0].Rows[i]["JobName"].ToString();
                        string path = ds.Tables[0].Rows[i]["Path"].ToString();
                        RecurringJob.AddOrUpdate(jobname, () => ConfigureJob(jobname,domain, username,password,remoteIP,path) ,
                        cronExp);
                        RecurringJob.Trigger(jobname);

                    }

                }
            }
            catch (Exception ex)
            {
                throw;
            }
            finally
            {

            }





            try
            {
                //string scriptText = "Invoke-Command -ComputerName localhost -ScriptBlock { D:\\SBIHangFireConsole.exe } ";
                //var password = new SecureString();
                //Array.ForEach("pass@2018".ToCharArray(), password.AppendChar);
                //PSCredential cred = new PSCredential("sbifm\\idealakes", password);
                
            
                //pipeline.Commands.AddScript(cred);
              
                //ps.Commands.AddArgument(cred);
               

                //ps.Commands.AddScript("$pass = cat C:\\securestring.txt | convertto-securestring");
                //ps.Commands.AddScript("$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist \"sbifm\\idealakes\",$pass");
                //ps.Commands.AddScript("Invoke-Command -ComputerName 192.168.26.60 -ScriptBlock { D:\\SBIHangFireConsole.exe } -cred $mycred");
                //ps.Commands.AddScript("Invoke-Command -ComputerName 192.168.26.60 -ScriptBlock { D:\\SBIHangFireConsole.exe }");
                //ps.AddParameter("cred", (PSCredential)cred);
                //ps.Commands.AddScript("$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist \"sbifm\\idealakes\",$pass");

               
                
                //ps.Commands.AddScript(@"C:\PowerShellBatFile.ps1");
               

            }
            catch (Exception ex)
            {
                throw;
            }

        }

        [DisplayName("{0}")]
        [AutomaticRetry(Attempts = 1)]
        public void ConfigureJob(string jobname, string domain, string username,string password, string remoteIP, string path)
        {
            Runspace runspace = RunspaceFactory.CreateRunspace();
            runspace.Open();
            Pipeline pipeline = runspace.CreatePipeline();
            PowerShell ps = PowerShell.Create();
            ps.Runspace = runspace;
            string script1 = "$User = \"" + domain + "\\" + username + "\"";
            string script2 = "$PWord = ConvertTo-SecureString -String \"" + password + "\" -AsPlainText -Force";
            string script3 = "$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord";
            string script4 = "Invoke-Command -ComputerName " + remoteIP + " -ScriptBlock { " + path + " } -cred $Credential";
            ps.Commands.AddScript(script1);
            ps.Commands.AddScript(script2);
            ps.Commands.AddScript(script3);
            ps.Commands.AddScript(script4);
            Collection<PSObject> resultst = ps.Invoke();
            Collection<ErrorRecord> errors = ps.Streams.Error.ReadAll();
            StringBuilder errorDetails = new StringBuilder();
            if (errors != null && errors.Count > 0)
            {
                foreach (ErrorRecord er in errors)
                {
                    errorDetails.AppendLine(er.Exception.ToString());

                }
                throw new Exception(errorDetails.ToString());
            }

            Console.WriteLine(errorDetails.ToString());
            StringBuilder stringBuilder = new StringBuilder();
            foreach (PSObject obj in resultst)
            {
                stringBuilder.AppendLine(obj.ToString());
            }
            Console.WriteLine(stringBuilder.ToString());
            runspace.Close();

        }
    }
}