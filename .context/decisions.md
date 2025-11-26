# Decision Log

> Architectural decisions with rationale for future reference.
> Record every significant choice so future-you understands WHY.

---

## Format

```markdown
### DEC-XXX: [Short Title]
**Date:** YYYY-MM-DD
**Status:** PROPOSED | APPROVED | SUPERSEDED
**Context:** Why is this decision needed?
**Decision:** What was decided?
**Rationale:** Why this over alternatives?
**Alternatives Considered:** What else was evaluated?
**Consequences:** What are the implications?
```

---

## Decisions

### DEC-001: Use FLAME over Audio2Face for Expression System
**Date:** 2025-11-21  
**Status:** APPROVED  
**Context:** Need a system to drive facial expressions from audio/text input for realistic Marcus avatar.  
**Decision:** Use FLAME model (MPI) for expression generation instead of NVIDIA Audio2Face.  
**Rationale:** 
- Community feedback indicates Audio2Face only handles lip sync
- FLAME provides unified system: lip sync + micro expressions + head movement + eyelid movement
- All derived from speech, creating more cohesive animation
- Better for crossing uncanny valley

**Alternatives Considered:**
- Audio2Face: Simpler setup but limited to lip sync only
- Custom blend shape system: Too much work for initial MVP
- Live Link Face: Requires iPhone for real-time capture

**Consequences:**
- Need to set up FLAME inference server
- Need to implement FLAME → MetaHuman blend shape mapping
- More complex but more realistic output

---

### DEC-002: Use Chatterbox over ElevenLabs for TTS
**Date:** 2025-11-21  
**Status:** APPROVED  
**Context:** Need text-to-speech for Marcus voice. Latency is critical.  
**Decision:** Use Chatterbox (local) instead of ElevenLabs (cloud API).  
**Rationale:**
- Local hosting eliminates API round-trip latency
- No per-character costs (stays within $2K budget)
- Full control over voice parameters
- Community recommendation

**Alternatives Considered:**
- ElevenLabs: Higher quality but API latency + costs
- Azure TTS: Microsoft lock-in, pricing complexity
- Coqui TTS: Good but Chatterbox has better community support

**Consequences:**
- Requires local GPU resources
- Need to fine-tune voice to match "educated Roman" character
- Full ownership of voice pipeline

---

### DEC-003: MetaHuman as Base Mesh Only
**Date:** 2025-11-21  
**Status:** APPROVED  
**Context:** Need photorealistic Marcus character. Options: full custom, Character Creator 4, MetaHuman.  
**Decision:** Use MetaHuman as base mesh, keeping topology/rig, rebuilding textures and reshaping face.  
**Rationale:**
- MetaHuman provides production-ready rig and subsurface profile
- Community approach: keep infrastructure, customize everything else
- Faster than full custom modeling
- Better quality than CC4 for photorealism

**Alternatives Considered:**
- Full custom model: Too time-consuming for solo dev
- Character Creator 4: Easier but lower photorealism ceiling
- 3D scan of bust: Limited expression capability

**Consequences:**
- Need Poly Hammer addon for Blender workflow (~$30)
- Expect 2+ weeks for character customization
- May need to work around MetaHuman limitations (root bone alignment, expression editor issues)

---

### DEC-004: Aegis-style .context/ for Persistent Memory
**Date:** 2025-11-21  
**Status:** APPROVED  
**Context:** Need persistent context across Cursor sessions without losing project knowledge.  
**Decision:** Use structured `.context/` directory with procedural/semantic/episodic memory files.  
**Rationale:**
- Zero dependencies (pure markdown)
- Human-readable and editable
- Works with any AI assistant
- Aligns with Cursor rules system

**Alternatives Considered:**
- Graphiti MCP: Requires server setup, more complex
- basic-memory MCP: Good but adds dependency
- Memory Bank: Similar approach but different structure

**Consequences:**
- Must manually maintain memory files
- Agent must read files at session start
- Scales well with project complexity

---

### DEC-005: BLUEPRINT → CONSTRUCT → VALIDATE Workflow
**Date:** 2025-11-21  
**Status:** APPROVED  
**Context:** Need to keep human in the loop, prevent AI from going off-rails.  
**Decision:** Enforce three-phase workflow with approval gates.  
**Rationale:**
- BLUEPRINT phase forces planning before coding
- NEEDS_PLAN_APPROVAL status requires explicit human confirmation
- CONSTRUCT follows approved plan exactly
- VALIDATE ensures quality gates are met
- Prevents scope creep and runaway implementation

**Alternatives Considered:**
- Free-form development: Too chaotic for complex project
- Waterfall: Too rigid for iterative work
- Pure agile: Lacks structure for AI assistance

**Consequences:**
- Slightly slower initial velocity
- Much higher quality and predictability
- Human always knows what's happening

---

### DEC-006: <2 Second E2E Latency Target
**Date:** 2025-11-21  
**Status:** APPROVED  
**Context:** Interactive avatar needs to feel responsive. What latency is acceptable?  
**Decision:** Target <2000ms total, hard limit <2800ms.  
**Rationale:**
- Community achieved 3.1s, targeting <2s for better UX
- Human conversation has natural pauses (~1-2s)
- Beyond 3s feels unresponsive
- Breakdown: LLM 800ms + TTS 400ms + FLAME 200ms + Network 200ms = 1600ms target

**Alternatives Considered:**
- <1s: Probably impossible with current tech for full pipeline
- <3s: Achievable but feels sluggish
- No target: Would lead to unmeasured creep

**Consequences:**
- Must instrument all pipeline stages
- Must optimize aggressively
- May need to cut features if latency suffers

---

### DEC-007: Introspection-Driven Architecture
**Date:** 2025-11-24  
**Status:** APPROVED  
**Context:** Marcus needs to adapt and learn from interactions, not just react to immediate input. Traditional chatbots lack memory and pattern recognition, making them repetitive and ineffective.  
**Decision:** Implement mandatory introspection layer where Marcus queries historical data before every response and measures effectiveness after.  
**Rationale:**
- **Self-awareness beats reactivity**: LLMs are stateless by default. Marcus needs to query what worked before.
- **Data-driven decisions**: Select communication strategies based on effectiveness scores, not random.
- **Continuous learning**: Each interaction updates strategy effectiveness, patterns, and behavioral models.
- **Prevents drift**: Without feedback loops, AI assistants go off-topic and repeat mistakes.
- **Question-driven development**: Every database table must answer specific real-time questions.

**Architecture:**
```
DialogueGenerator (Brain)
    ↓
IntrospectionService (Nervous System)
    ↓
[PatternRepository, StrategyRepository, PADStateRepository, BehavioralRepository]
    ↓
[Database: patterns, strategies, pad_states, behavioral_states]
```

**Introspection Flow:**
1. **Before Response**: Query patterns, strategies, emotional trajectory, relationship stage
2. **Strategy Selection**: Use data to choose approach (supportive/energizing/balanced/etc.)
3. **Generate Response**: Context-aware prompt with strategy + patterns + warnings
4. **After Response**: Measure effectiveness, update strategy scores, detect new patterns
5. **Record State**: Save real behavioral state (not hardcoded)

**Alternatives Considered:**
- **Reactive-only (no introspection)**: Simpler but Marcus would never learn or adapt
- **ML-based pattern detection**: More accurate but adds latency and complexity (use later)
- **Post-conversation analytics**: Useful for humans but doesn't help Marcus adapt in real-time
- **External memory service**: Adds network latency; keeping it in-database is faster

**Consequences:**
- **+50-100ms latency per response** (introspection queries): Acceptable within 2s budget
- **Complexity increase**: 3 new repositories + IntrospectionService + updated generator
- **Learning curves**: Strategy effectiveness improves over time (cold start problem)
- **Data requirements**: Patterns/strategies meaningful only after 10+ interactions per user
- **Maintenance**: Must ensure introspection queries stay <50ms (index properly)
- **Development discipline**: All future features must follow "introspection-driven" protocol

**Implementation Files:**
- `src/domain/repositories.py`: Added PatternRepository, StrategyRepository, enhanced PADStateRepository
- `src/domain/introspection.py`: New IntrospectionService (Marcus's nervous system)
- `src/dialogue/generator.py`: Updated DialogueGenerator with mandatory introspection
- `AGENTS.md`: Added introspection rules and checklist

**Success Metrics:**
- Strategy effectiveness scores increase over time (learning curve)
- Relationship stage evolves dynamically (Stranger → Acquaintance → Trusted)
- Pattern confidence scores reflect real behaviors
- Crisis detection and intervention reduce negative streaks
- No hardcoded behavioral states in production responses

