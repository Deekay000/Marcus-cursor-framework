# Marcus AI Avatar

A self-aware conversational AI system inspired by Marcus Aurelius' Stoic philosophy, featuring emotional awareness (PAD model), introspection, and adaptive learning.

**Current Status**: MVP - Consolidated monolithic backend with full emotional tracking and introspection capabilities.

---

## Features

### Core Capabilities ✅
- **Emotional Awareness**: PAD (Pleasure-Arousal-Dominance) emotional model with decay dynamics
- **Introspection System**: Self-aware pattern detection and strategy selection based on effectiveness data
- **Adaptive Learning**: Learns from interaction outcomes and adjusts communication style
- **Stoic Persona**: Authentic Marcus Aurelius communication style (direct, grounded, piercing)
- **Conversation Memory**: Full context retention across sessions

### Technical Stack
- **Backend**: FastAPI with async Python 3.10+
- **Database**: PostgreSQL (conversation history, emotional states, behavioral patterns)
- **Cache**: Redis (session management, performance optimization)
- **LLM**: OpenAI GPT-4 (wrapped for testability and swappability)
- **Monitoring**: Prometheus + Grafana (metrics and observability)

### Architecture Patterns
- **Layered Architecture**: Clear separation (API → Service → Domain → Infrastructure)
- **Repository Pattern**: Abstracted data access
- **Adapter Pattern**: External service wrappers (LLMClient)
- **Strategy Pattern**: Swappable emotional models
- **Dependency Injection**: Testable, flexible design

---

## Quick Start

### Prerequisites

- Docker & Docker Compose
- OpenAI API key
- Python 3.10+ (for local development/testing)

### Setup

```bash
# 1. Clone and setup environment
cp .env.example .env
# Add your OpenAI API key to .env: OPENAI_API_KEY=sk-...

# 2. Start services
docker-compose up -d

# 3. Initialize database
docker-compose exec api python scripts/init_db.py

# 4. Verify system health
curl http://localhost:8000/health

# 5. Test the chat API
curl -X POST http://localhost:8000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"content": "Hello Marcus, what is the good life?"}'
```

**Services running**:
- API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001 (admin/admin)

---

## Project Structure

```
iza/
├── src/
│   ├── api/              # HTTP layer (routes, dependencies)
│   │   ├── main.py      # FastAPI app
│   │   └── routes/      # Endpoint definitions
│   ├── domain/           # Business logic & models
│   │   ├── models.py    # SQLAlchemy models (User, Session, Message)
│   │   ├── repositories.py  # Data access layer
│   │   ├── services.py  # Business logic orchestration
│   │   └── introspection.py # Self-awareness system
│   ├── dialogue/         # AI-specific logic
│   │   ├── generator.py # Core dialogue brain
│   │   └── pad_logic.py # Emotional calculations
│   └── infrastructure/   # External systems
│       ├── database.py  # PostgreSQL
│       ├── redis.py     # Redis cache
│       ├── logging.py   # Structured logging
│       ├── metrics.py   # Prometheus metrics
│       └── external/    # External service wrappers
│           └── llm_client.py  # OpenAI adapter
├── tests/
│   ├── unit/            # Fast, isolated tests
│   └── integration/     # Tests with real DB
├── scripts/             # Utility scripts
├── sql/                 # Database schemas
├── ARCHITECTURE.md      # Technical architecture guide
└── docker-compose.yml   # Service orchestration
```

---

## API Endpoints

### Chat API

**Simplified Chat** (recommended for MVP):
```bash
POST /api/v1/chat
{
  "content": "What is the good life?"
}
```

**Session Management**:
```bash
# Create session
POST /api/v1/sessions
{
  "external_id": "user_123",
  "display_name": "Alice"
}

# Chat with session
POST /api/v1/sessions/{session_id}/chat
{
  "content": "Hello Marcus"
}

# Get history
GET /api/v1/chat/history
```

**System Endpoints**:
- `GET /health` - Health check
- `GET /metrics` - Prometheus metrics

**Interactive API Docs**: http://localhost:8000/docs

### Example Response

```json
{
  "response": "You control your mind. Not external events. Realize this, and you find strength.",
  "pad": {
    "pleasure": 0.12,
    "arousal": -0.15,
    "dominance": 0.25
  },
  "quadrant": "Dependent",
  "strategy_used": "balanced",
  "effectiveness": 0.72,
  "relationship_stage": "Stranger",
  "patterns_detected": [],
  "warning_flags": []
}
```

---

## Testing

```bash
# Install test dependencies
pip install pytest pytest-asyncio pytest-cov httpx

# Run all tests
pytest tests/

# Run with coverage
pytest tests/ --cov=src --cov-report=term-missing

# Run specific test file
pytest tests/unit/test_pad_logic.py -v

# Run linter
ruff check src/
```

**Test Coverage Targets**:
- Unit tests: 80%+ on `src/dialogue/` and `src/domain/`
- Integration tests: All API endpoints tested
- E2E tests: At least one happy path

---

## Development

### Local Development Setup

```bash
# 1. Create virtual environment
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows

# 2. Install dependencies
pip install -r requirements.txt

# 3. Set environment variables
export DATABASE_URL="postgresql+asyncpg://marcus:password@localhost/marcus_dev"
export REDIS_URL="redis://localhost:6379/0"
export OPENAI_API_KEY="sk-..."

# 4. Run API locally
uvicorn src.api.main:app --reload --port 8000

# 5. Run tests
pytest tests/ -v
```

### Code Quality

```bash
# Type checking
mypy src/

# Linting
ruff check src/

# Formatting
ruff format src/

# Run all checks
ruff check src/ && pytest tests/ && mypy src/
```

---

## Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture, design patterns, coding standards
- **[API Docs](http://localhost:8000/docs)** - Interactive OpenAPI documentation
- **[.cursor/rules/marcus-ai.mdc](.cursor/rules/marcus-ai.mdc)** - Development rules for Cursor AI

---

## Monitoring

- **Prometheus**: http://localhost:9090 - Metrics collection
- **Grafana**: http://localhost:3001 - Visualization dashboards (admin/admin)

**Key Metrics**:
- `marcus_requests_total` - Request count by endpoint
- `marcus_request_duration_seconds` - API latency
- `marcus_llm_latency_seconds` - LLM call duration
- `marcus_emotional_state` - Current PAD values

---

## Contributing

### Development Workflow

1. **Create feature branch**: `git checkout -b feature/your-feature`
2. **Write tests first**: Test-driven development
3. **Implement feature**: Follow layered architecture
4. **Run tests**: `pytest tests/`
5. **Run linter**: `ruff check src/`
6. **Commit with message**: See [ARCHITECTURE.md](ARCHITECTURE.md#git-workflow)
7. **Create PR**: Include tests and documentation

### Coding Standards

See [ARCHITECTURE.md](ARCHITECTURE.md#coding-standards) for detailed standards.

**Quick rules**:
- Type annotations on all functions
- Async for all I/O operations
- No TODOs without issue links
- Functions < 30 lines
- 80%+ test coverage on business logic

---

## Troubleshooting

### Database connection failed
```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Reinitialize database
docker-compose exec api python scripts/reset_db.py
docker-compose exec api python scripts/init_db.py
```

### OpenAI API errors
```bash
# Verify API key is set
docker-compose exec api printenv | grep OPENAI_API_KEY

# Check API key validity
docker-compose exec api python scripts/verify_api.py
```

### Tests failing
```bash
# Install test dependencies
pip install pytest pytest-asyncio pytest-cov httpx

# Run with verbose output
pytest tests/ -v --tb=short

# Run single test
pytest tests/unit/test_pad_logic.py::TestPADLogic::test_positive_stimulus_increases_pleasure -v
```

---

## License

MIT License - See LICENSE file for details

---

## Roadmap

### ✅ Phase 1: MVP (Complete)
- [x] Core chat API
- [x] PAD emotional model
- [x] Introspection system
- [x] Pattern detection
- [x] Strategy selection
- [x] Conversation persistence

### 🔄 Phase 2: Enhanced UX (In Progress)
- [ ] Web UI (React/Next.js)
- [ ] Real-time emotional visualization
- [ ] Conversation analytics dashboard

### 📋 Phase 3: Advanced Features (Planned)
- [ ] FLAME facial expressions
- [ ] TTS voice synthesis (Chatterbox)
- [ ] Multi-language support
- [ ] Advanced prompt engineering
- [ ] Behavioral pattern learning

---

**Version**: 1.0.0  
**Last Updated**: 2025-11-26  
**Status**: Active Development
