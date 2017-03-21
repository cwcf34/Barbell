﻿using IdentityServer3.Core;
using IdentityServer3.Core.Models;
using IdentityServer3.Core.Services.InMemory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Web;

namespace OAuthIS3
{
    public class InMemoryManager
    {
        public List<InMemoryUser> GetUsers()
        {
            return new List<InMemoryUser>
            {
                new InMemoryUser
                {
                    Subject = "alice",
                    Username = "alice",
                    Password = "password",
                    Claims = new []
                    {
                        new Claim(Constants.ClaimTypes.Name, "alice")
                    }
                }
            };
        }

        public IEnumerable<Scope> GetScopes()
        {
            return new[]
            {
                StandardScopes.OpenId,
                StandardScopes.Profile,
                StandardScopes.OfflineAccess,
                new Scope
                {
                    Name = "WebAPI",
                    DisplayName = "Access to the web api"
                }
            };
        }

        public IEnumerable<Client> GetClients()
        {
            return new[]
            {
                new Client
                {
                    ClientId = "iOS",
                    ClientSecrets = new List<Secret>
                    {
                        new Secret("secret".Sha256())
                    },
                    ClientName = "iOS",
                    Flow = Flows.ResourceOwner,
                    AllowedScopes = new List<string>
                    {
                        Constants.StandardScopes.OpenId,
                        Constants.StandardScopes.Profile,
                        Constants.StandardScopes.OfflineAccess,
                        "WebAPI"
                    },
                    Enabled = true
                }
            };
        }
    }
}