using IdentityServer3.Core.Services.Default;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using IdentityServer3.Core.Models;
using IdentityServer3.Core.Services;
using System.Threading.Tasks;

namespace OAuthIS3
{
    public class UserService : UserServiceBase
    {
        public override async Task AuthenticateLocalAsync(LocalAuthenticationContext context)
        {
            User user = DBController.findUser(context.UserName);
            //Return an error if the user was not found
            if (user != null)
            {
                //Compare passwords
                if ((context.Password).Sha512().Equals(user.Password))
                {
                    //Success case
                    context.AuthenticateResult = new AuthenticateResult(user.Email, "User Name");
                    return;
                }

            }

            //Error case
            context.AuthenticateResult = new AuthenticateResult("Incorrect email or password");
            return;
        }
    }
}