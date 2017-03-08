using IdentityServer4.Models;
using IdentityServer4.Test;
using IdentityServer4.Validation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using static IdentityModel.OidcConstants;

namespace OAuth
{
    public class PasswordValidator : IResourceOwnerPasswordValidator
    {
        public Task ValidateAsync(ResourceOwnerPasswordValidationContext context)
        {

            User user = DBModel.findUser(context.UserName);
            //Return an error if the user was not found
            if (user != null)
            {
                //Compare passwords
                if ((context.Password).Sha512().Equals(user.Password))
                {
                    context.Result = new GrantValidationResult(
                        subject: user.Email,
                        authenticationMethod: AuthenticationMethods.Password
                    );
                    return Task.FromResult(0);
                }

            }

            //Error case
            context.Result = new GrantValidationResult(
                TokenRequestErrors.InvalidRequest,
                "Invalid email or password");
            return Task.FromResult(0);

        }
    }
}
