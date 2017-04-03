using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Security.Claims;
using System.Web.Http;

namespace BBAPI.Helpers
{
    /// <summary>
    /// A static class full of functions for JSON Web Tokens
    /// </summary>
    public static class JwtHelper
    {
        /// <summary>
        /// Extracts the "sub" claim from claimsPrincipal
        /// </summary>
        /// <param name="bearerToken">A claims principal to extract the "sub" value from</param>
        /// <returns>The email of claimsPrincipal in the success case, otherwise an empty string</returns>
        public static string getEmail(ClaimsPrincipal claimsPrincipal)
        {
            return (claimsPrincipal != null) 
                ? claimsPrincipal.FindFirst("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier").Value 
                : "";
        }
    }
}