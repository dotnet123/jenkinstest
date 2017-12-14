using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace app
{
    public class Program
    {
        private static readonly HttpClientHandler HttpClientHandler = new HttpClientHandler
        {
            AutomaticDecompression = DecompressionMethods.GZip,
            //MaxRequestContentBufferSize = 1024 * 1024
            MaxConnectionsPerServer = 20,


        };

        private static readonly HttpClient HttpClient = new HttpClient(HttpClientHandler)
        {
            Timeout = TimeSpan.FromSeconds(500)
        };
        public static void Main(string[] args)
        {
            //BuildWebHost(args).Run();
            while (true)
            {
                int count = 10000;
                string url = "http://10.1.4.222:5000/api/values";
                CountdownEvent cde = new CountdownEvent(count);
                Stopwatch sw = new Stopwatch();
                sw.Start();
                Parallel.For(0, count, i =>
                {

                    HttpClient.GetStringAsync(url).ContinueWith((t) =>
                    {
                        if (t.Exception != null)
                        {
                            Console.WriteLine(t.Exception.Message);
                        }
                        cde.Signal();


                    });
                });
                cde.Wait();
                sw.Stop();
                Console.WriteLine(sw.ElapsedMilliseconds);
            }
        
            // App.Init();
            // BuildWebHost(args).Run();
            Console.Read();
            
        }

        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>()
            
            .UseUrls("http://*:5000")
                .Build();
    }
}
