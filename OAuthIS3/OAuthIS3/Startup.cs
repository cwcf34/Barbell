using System;
using System.Threading.Tasks;
using Microsoft.Owin;
using Owin;
using IdentityServer3.Core.Configuration;
using System.Security.Cryptography.X509Certificates;
using System.Configuration;
using IdentityServer3.Core.Services;

[assembly: OwinStartup(typeof(OAuthIS3.Startup))]

namespace OAuthIS3
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            var inMemoryManager = new InMemoryManager();
            var factory = new IdentityServerServiceFactory()
                .UseInMemoryUsers(inMemoryManager.GetUsers())
                .UseInMemoryScopes(inMemoryManager.GetScopes());

            factory.UserService = new Registration<IUserService>(
                typeof(UserService));

            var certificate = Convert.FromBase64String(ConfigurationManager.AppSettings["SigningCertificate"]);

            var options = new IdentityServerOptions
            {
                SigningCertificate = new X509Certificate2(certificate, ConfigurationManager.AppSettings["SigningCertificatePassword"]),
                RequireSsl = false, // DO NOT DO THIS IN PRODUCTION
                Factory = factory
            };

            app.UseIdentityServer(options);
        }
    }
}
