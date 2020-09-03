function GenerateReponseObject {
    PARAM(
        [validateset(
            "Accepted",
            "AlreadyReported",
            "Ambiguous",
            "BadGateway",
            "BadRequest",
            "Conflict",
            "Continue",
            "Created",
            "EarlyHints",
            "ExpectationFailed",
            "FailedDependency",
            "Forbidden",
            "Found",
            "GatewayTimeout",
            "Gone",
            "HttpVersionNotSupported",
            "IMUsed",
            "InsufficientStorage",
            "InternalServerError",
            "LengthRequired",
            "Locked",
            "LoopDetected",
            "MethodNotAllowed",
            "MisdirectedRequest",
            "Moved",
            "MovedPermanently",
            "MultipleChoices",
            "MultiStatus",
            "NetworkAuthenticationRequired",
            "NoContent",
            "NonAuthoritativeInformation",
            "NotAcceptable",
            "NotExtended",
            "NotFound",
            "NotImplemented",
            "NotModified",
            "OK",
            "PartialContent",
            "PaymentRequired",
            "PermanentRedirect",
            "PreconditionFailed",
            "PreconditionRequired",
            "Processing",
            "ProxyAuthenticationRequired",
            "Redirect",
            "RedirectKeepVerb",
            "RedirectMethod",
            "RequestedRangeNotSatisfiable",
            "RequestEntityTooLarge",
            "RequestHeaderFieldsTooLarge",
            "RequestTimeout",
            "RequestUriTooLong",
            "ResetContent",
            "SeeOther",
            "ServiceUnavailable",
            "SwitchingProtocols",
            "TemporaryRedirect",
            "TooManyRequests",
            "Unauthorized",
            "UnavailableForLegalReasons",
            "UnprocessableEntity",
            "UnsupportedMediaType",
            "Unused",
            "UpgradeRequired",
            "UseProxy",
            "VariantAlsoNegotiates"
        )][parameter(Mandatory=$true)][string]$HttpStatusCode,
        [parameter(Mandatory=$false)][string]$Body
    )
    $hash = [hashtable]@{
        Name = "Response"
        Value = [HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::$HttpStatusCode
            Body       = $($Body | ConvertTo-Json)
        }
    }

    Push-OutputBinding @hash
}