# HelixCD Security Policy

## Supported Versions
| Version | Supported |
|---------|-----------|
| latest  | ✅        |
| < 1.0   | ❌        |

## Reporting a Vulnerability

### DO NOT open public GitHub Issues
### for security vulnerabilities

### Contact
GitHub: @ShamshabadAnil (DM)
Response time: 48 hours maximum

### What To Include
- Description of vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Process After Report
1. We confirm receipt within 48 hours
2. We assess severity within 5 days
3. We develop fix within timeline:
   - CRITICAL: 24 hours
   - HIGH:     7 days
   - MEDIUM:   30 days
   - LOW:      90 days
4. We release fix
5. We credit reporter (if desired)
6. We publish advisory after fix

### Safe Harbor
We will not take legal action against
researchers who report vulnerabilities
in good faith following this policy.

### Hall of Fame
Security researchers who help us
will be credited in our CHANGELOG
and README (with permission).

## Security Design Principles
- Local LLM (data never leaves your machine)
- Command whitelist (no arbitrary execution)
- Secrets never in code or logs
- Docker network isolation
- No root in containers
- All inputs validated
- All external calls error-handled
