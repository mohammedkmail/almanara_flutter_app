import grails.util.Environment
import java.security.SecureRandom

// JSON/Bearer authentication for Flutter; the existing website keeps its form session.
grails.plugin.springsecurity.rest.login.endpointUrl = '/api/login'
grails.plugin.springsecurity.rest.login.useJsonCredentials = true
grails.plugin.springsecurity.rest.token.storage.jwt.expiration = 3600
grails.plugin.springsecurity.rest.token.storage.jwt.refreshExpiration = 3600

def jwtSecret = System.getenv('JWT_SECRET')
if (!jwtSecret && Environment.current != Environment.PRODUCTION) {
    byte[] bytes = new byte[48]
    new SecureRandom().nextBytes(bytes)
    jwtSecret = bytes.encodeBase64().toString()
}
// Production must supply JWT_SECRET. Development tokens expire on server restart.
grails.plugin.springsecurity.rest.token.storage.jwt.secret = jwtSecret

