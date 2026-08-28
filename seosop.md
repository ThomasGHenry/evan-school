# Standard Operating Procedure

## Technical SEO / Generative Engine Optimization / Answer Engine Optimization

| Document-control field    | Value                                                 |
| ------------------------- | ----------------------------------------------------- |
| **Document ID**           | SOP-DIG-SEO-GEO-001                                   |
| **Version**               | 1.0                                                   |
| **Status**                | Draft for Review                                      |
| **Effective date**        | [YYYY-MM-DD]                                          |
| **Document owner**        | [Head of Organic Growth / SEO Lead / Digital Product] |
| **Approved by**           | [Name/Role]                                           |
| **Next review date**      | [YYYY-MM-DD]                                          |
| **Classification**        | Internal Controlled Document                          |
| **Change classification** | Initial issue                                         |
| **Source framework**      | SOP-QMS-001 v2.0                                      |

This draft intentionally follows the control architecture in the uploaded **SOP Lifecycle and Control Framework**: explicit outcomes, dual execution/definition lifecycles, observable states, metric registries, threshold-action mappings, feedback latency, piloting, rollback, change classification, and lifecycle review.

---

# 1. Purpose

This SOP establishes the controlled method for auditing, implementing, measuring, improving, and governing:

**Technical/on-site Search Engine Optimization (SEO)**
**Generative Engine Optimization (GEO)**
**Answer Engine Optimization (AEO)**

for [Organization Name] digital properties.

The procedure exists to produce the following outcome:

> **Eligible, technically accessible, authoritative digital content that can be discovered, crawled, rendered, indexed, retrieved, ranked or cited, presented accurately in search and generative-answer systems, and converted into measurable business outcomes without degrading user experience or creating uncontrolled search risk.**

Completing SEO tasks is not itself success.

The procedure must produce measurable improvements in the relevant stages of:

**Access → Crawl → Render → Canonicalize → Index → Retrieve → Rank/Cite → Engage → Convert → Learn**

Google currently states that pages shown as supporting links in AI Overviews or AI Mode must be **indexed and eligible to appear in Google Search with a snippet**, and that there are no separate technical requirements for inclusion. ([Google Developers][1])

---

# 2. Scope

This SOP applies to:

- public websites;
- ecommerce sites;
- publishers;
- SaaS/product sites;
- documentation sites;
- marketplace pages;
- programmatic landing pages;
- international sites;
- JavaScript applications;
- editorial content;
- product/category pages;
- structured data;
- internal linking systems;
- search-facing templates;
- AI-search crawler controls;
- organic-search reporting;
- AI citation/retrieval measurement.

It applies to:

**new sites, migrations, redesigns, CMS changes, template changes, content programs, structured-data deployment, internal-linking changes, URL changes, GEO/AEO experiments, and ongoing optimization.**

It does not automatically apply to:

- paid search;
- paid social;
- app-store optimization;
- closed intranet systems;
- purely internal search;
- AI training-data strategy except where crawler controls overlap with search discovery.

Controls must remain proportionate to risk, consistent with the source framework.

---

# 3. Governing principles

## 3.1 Eligibility before optimization

A page that cannot be crawled, rendered, indexed, or selected as the correct canonical cannot reliably benefit from downstream GEO/AEO optimization.

Priority order:

**technical eligibility → retrieval → citation/answer usefulness → engagement → conversion**

---

## 3.2 Outcomes before activity

Do not judge the program by:

- number of pages published;
- schema items added;
- tickets closed;
- keywords inserted;
- prompts tested;
- backlinks merely counted;
- audits completed.

Judge it by observable outcomes.

---

## 3.3 Evidence before opinion

SEO/GEO decisions must use evidence from appropriate sources, including:

- crawler data;
- HTTP responses;
- rendered HTML;
- server/CDN logs;
- Google Search Console;
- Bing Webmaster Tools;
- analytics;
- structured-data validation;
- controlled prompt/query monitoring;
- conversion data;
- user behavior;
- approved experiments.

Single screenshots from an AI system are insufficient evidence for a material decision.

---

## 3.4 SEO is the substrate for GEO/AEO

For Google specifically, foundational SEO remains applicable to AI Overviews and AI Mode, and Google says no special optimization is required merely because the result is generative. ([Google Developers][2])

Therefore:

**GEO/AEO must extend technical SEO, not bypass it.**

---

## 3.5 Retrieval and citation are different states

The organization must distinguish:

**indexed**
from
**retrieved**
from
**cited**
from
**meaningfully contributing to an answer**

These states must not be collapsed into a single “AI visibility score.”

---

## 3.6 Platform evidence has precedence over vendor folklore

Search-engine documentation, observable crawl/index behavior, controlled tests, and first-party reporting take precedence over unsupported third-party claims.

Examples:

Google says no new machine-readable AI file or special schema.org markup is required for its AI Search features. ([Google Developers][3])

---

## 3.7 Human usefulness remains a guardrail

Optimization must not materially worsen:

- factual accuracy;
- accessibility;
- readability;
- page experience;
- conversion ability;
- legal/compliance integrity;
- customer trust.

---

## 3.8 Reversible change is preferred

Large search-facing changes should be:

**isolated → tested → progressively released → observed → expanded or rolled back**

where feasible.

---

# 4. Definitions

### AEO — Answer Engine Optimization

Optimization of information so that it can accurately satisfy a question or task and be extracted, summarized, referenced, or presented by answer systems.

### Canonical URL

The URL treated as the representative version of duplicate or substantially similar content.

### Citation

A displayed source reference from an AI-generated answer to a page or domain.

### Citation rate

Internal experimental metric:

`prompts producing ≥1 citation to owned content / eligible tested prompts`

It must not be represented as a native search-engine metric unless the engine explicitly reports it.

### Crawl eligibility

Whether the intended crawler is technically permitted and capable of requesting the URL/resources required to understand it.

### GEO — Generative Engine Optimization

Optimization of web information for participation in retrieval-grounded generative experiences, including discoverability, retrieval, citation, grounding, and answer contribution.

### Grounding query

A retrieval phrase used by an AI/search system to locate evidence for an answer. Bing Webmaster Tools exposes sampled grounding queries in its AI Performance reporting. ([Bing Blogs][4])

### Guardrail metric

A metric that must remain within an approved range while another outcome is optimized.

### Index eligibility

Whether a page satisfies the conditions necessary to be considered for inclusion in a search index.

### Information gain

Useful information not merely reproduced from existing commodity sources, such as:

- original research;
- proprietary data;
- expert interpretation;
- first-hand testing;
- novel examples;
- unique comparisons;
- direct operational experience.

### Minimum evidence requirement

The minimum observation period, sample, cohort, event count, or quality of evidence required before a decision.

### OAI-SearchBot

OpenAI crawler associated with discovery for ChatGPT search surfaces.

### GPTBot

Separate OpenAI crawler relevant to potential model-training controls.

OpenAI explicitly documents these as distinct controls. ([OpenAI Help Center][5])

### Retrieval

Selection of a page/document as evidence or context for a search or generative-answer process.

### Technical SEO

Engineering and information-architecture controls that influence crawler access, rendering, indexing, canonicalization, internal discovery, machine interpretation, and search performance.

---

# 5. Roles and responsibilities

## 5.1 Document owner

Usually:

**Head of Organic Growth / SEO Director / Digital Product Owner**

Must:

- own this SOP;
- approve program scope;
- assign decision authorities;
- approve material thresholds;
- maintain review cadence;
- initiate revision or retirement.

---

## 5.2 SEO/GEO execution owner

Must:

- confirm valid audit/change start conditions;
- monitor evidence;
- classify findings;
- maintain remediation backlog;
- issue P0 escalations;
- verify closure.

---

## 5.3 Technical SEO lead

Owns:

- crawling;
- indexation;
- canonicalization;
- sitemaps;
- HTTP behavior;
- internal discovery;
- rendering;
- JavaScript SEO;
- structured-data technical integrity.

---

## 5.4 Content/AEO lead

Owns:

- intent satisfaction;
- entity clarity;
- answer construction;
- evidence quality;
- attribution;
- content architecture;
- information gain;
- content freshness.

---

## 5.5 Engineering owner

Owns:

- platform implementation;
- template behavior;
- redirects;
- rendering;
- server configuration;
- structured-data implementation;
- instrumentation;
- rollback capability.

---

## 5.6 Analytics/metric owner

Must:

- maintain metric definitions;
- validate calculation logic;
- identify missing/delayed data;
- preserve historical comparability;
- prevent silent metric-definition changes.

This role follows the uploaded framework's separation of metric ownership, systems ownership, execution ownership, and improvement ownership.

---

## 5.7 Content subject-matter expert

Must verify:

- factual correctness;
- expert claims;
- quantitative evidence;
- examples;
- limitations;
- source attribution.

---

## 5.8 Final approver

Must approve material changes affecting:

- URL architecture;
- sitewide indexing;
- canonical logic;
- crawler policy;
- major rendering architecture;
- large programmatic content programs;
- organization-wide schema;
- migrations.

---

# 6. Control architecture

The source framework requires linked execution and definition lifecycles and an:

**Execute → observe → compare → decide → act → verify → learn**

control loop.

This SOP implements that model as follows.

---

# 7. SEO/GEO execution lifecycle

Each audit, remediation program, or experiment uses the applicable states below.

| State                        | Meaning                                                            |
| ---------------------------- | ------------------------------------------------------------------ |
| **Not eligible**             | Required inputs, access, authority, or baseline unavailable        |
| **Ready**                    | Scope, owner, evidence sources, baseline and permissions confirmed |
| **Started**                  | Execution formally initiated                                       |
| **Discovery**                | Crawl/data/query evidence being collected                          |
| **Diagnosed**                | Findings classified and causal hypothesis recorded                 |
| **Remediation ready**        | Fix designed, validated and approved where necessary               |
| **In implementation**        | Change deployed to test/pilot environment or cohort                |
| **At risk**                  | Guardrail/threshold deterioration detected                         |
| **Paused**                   | Work held pending evidence/authority                               |
| **Escalated**                | Decision transferred to higher authority                           |
| **Rolling back**             | Previous approved state being restored                             |
| **Validated**                | Expected behavior confirmed technically                            |
| **Measuring**                | Outcome window running                                             |
| **Completed**                | Acceptance criteria satisfied                                      |
| **Completed with exception** | Outcome accepted with documented residual issue                    |
| **Failed**                   | Required outcome not achieved                                      |
| **Closed**                   | Records complete and learning entered into backlog                 |

---

# 8. SOP definition lifecycle

Use:

**Proposed → Draft → Under review → Instrumented → Pilot-ready → In pilot → Approved → Ramping → Steady state → Under optimization → Under material revision → Suspended → Replaced → Retired → Archived**

consistent with the parent control framework.

---

# 9. Intended outcome and theory of control

## 9.1 Intended outcome

Produce reliable search and generative-answer visibility for useful organizational information while preserving technical integrity and business value.

---

## 9.2 Unit of analysis

Depending on the decision:

- URL;
- canonical cluster;
- template;
- directory;
- topic;
- entity;
- query;
- grounding query;
- prompt;
- domain;
- market;
- language;
- site release;
- conversion cohort.

Every metric must specify its unit.

---

## 9.3 Causal model

The working theory is:

**crawler access**
→ allows **discovery/fetching**

**valid rendering + correct HTTP behavior**
→ allows **content interpretation**

**canonical/index controls**
→ allow **correct index representation**

**architecture/internal links**
→ improve **discovery and contextual relationships**

**semantic clarity + useful content**
→ improve **retrieval relevance**

**original evidence + extractable answers**
→ improve **citation/answer utility**

**good UX + intent alignment**
→ improve **qualified engagement/conversion**

The causal model must be tested rather than treated as guaranteed.

---

# 10. Mandatory controls

The following controls are mandatory for any strategic search property.

### Technical

- crawler access intentionally configured;
- valid status codes;
- canonical policy;
- index directives;
- crawlable navigation;
- valid canonical sitemap generation;
- search-engine verification;
- rendering validation;
- mobile parity;
- deployment rollback capability.

### Content

- explicit page purpose;
- accurate factual claims;
- responsible ownership;
- appropriate primary sourcing;
- no uncontrolled mass generation;
- visible-content/schema agreement.

### Measurement

- GSC installed;
- Bing Webmaster Tools installed where applicable;
- analytics installed;
- baseline recorded;
- pre/post evidence retained.

---

# 11. Procedure

## 11.1 Initiate an audit or optimization request

Requester must provide:

- business objective;
- property/domain;
- market/language;
- affected templates;
- current issue or opportunity;
- known risks;
- target date;
- expected business outcome.

Execution owner assigns:

**P0 / P1 / P2 operational priority.**

---

# 12. Priority classification

## P0 — blocker / material search risk

Can materially prevent or corrupt:

- crawling;
- rendering;
- indexing;
- canonicalization;
- site availability;
- large-scale search eligibility.

Target response:

**immediate triage; same operational day where feasible.**

Examples:

- production `noindex`;
- robots.txt blocking critical sections;
- canonicalizing most pages to the wrong URL;
- widespread `5xx`;
- broken rendering of primary content;
- accidental staging-to-production crawler block.

---

## P1 — material performance opportunity

Does not usually eliminate eligibility but materially limits:

- retrieval;
- rankings;
- citation;
- semantic understanding;
- content usefulness;
- business outcome.

Target:

**current or next optimization sprint.**

---

## P2 — optimization / experiment

Useful but generally non-blocking.

Examples:

- refinement of answer blocks;
- advanced entity enhancements;
- AI prompt monitoring expansion;
- marginal crawl optimization.

---

# 13. Audit execution

The execution owner must evaluate the following ten control domains.

---

# Domain A — Crawl accessibility

1. Googlebot access
2. Bingbot access
3. OAI-SearchBot policy
4. robots.txt validity
5. valid `200` responses
6. `404/410/301` behavior
7. soft-404 detection
8. critical resource accessibility
9. CDN/WAF/bot-control behavior
10. crawler log verification

OpenAI states that sites wanting their content included in summaries/snippets should not block `OAI-SearchBot`; it separately documents `GPTBot` for training controls. ([OpenAI Help Center][5])

---

# Domain B — Indexability and canonicalization

11. unintended `noindex`
12. crawlability of `noindex` URLs
13. self-canonical behavior
14. duplicate canonical consolidation
15. canonical signal alignment
16. HTTP→HTTPS consolidation
17. preferred host normalization
18. parameter duplication
19. pagination behavior
20. search-engine canonical verification

Google notes that `noindex` can only be read when the crawler can access the page. ([Google Developers][6])

Google currently describes redirects and `rel="canonical"` as strong canonicalization signals and sitemap inclusion as weaker. ([Google Developers][7])

---

# Domain C — Sitemaps and discovery

21. sitemap contains intended canonical URLs
22. absolute URLs
23. sitemap size compliance
24. meaningful `lastmod`
25. diagnostic sitemap segmentation
26. Search Console submission
27. sitemap discoverability
28. orphan-page detection
29. crawlable HTML links
30. stable SPA/application URLs

Google limits individual sitemap files to **50 MB uncompressed or 50,000 URLs**. ([Google Developers][8])

Google also recommends crawlable `<a href>` links; script-like pseudo-links should not be relied upon for discovery. ([Google Developers][9])

---

# Domain D — Architecture and internal linking

31. strategic-page click depth
32. descriptive internal anchors
33. topic/entity hubs
34. breadcrumbs
35. crawlable main navigation
36. authority distribution
37. semantic contextual links
38. related-content relevance
39. canonical destination linking
40. facet/filter crawl controls

---

# Domain E — Rendering and page experience

41. rendered primary content
42. critical JS/API dependency resilience
43. metadata stability after rendering
44. rendering error detection
45. mobile content parity
46. LCP monitoring
47. INP monitoring
48. CLS monitoring
49. HTTPS/resource integrity
50. intrusive interface review

Google documents JavaScript processing as a crawl → render → index pipeline and notes that robots-blocked pages/resources are not rendered by Google. ([Google Developers][10])

---

# Domain F — On-page semantics

51. unique descriptive titles
52. explicit primary heading
53. meaningful heading structure
54. direct answer where appropriate
55. intent completeness
56. entity disambiguation
57. explicit dates/units/version/scope
58. semantic HTML
59. media context
60. primary-source attribution

---

# Domain G — Structured data and entity integrity

61. schema syntax validity
62. appropriate supported type
63. required properties
64. visible-content parity
65. organization identity consistency
66. author/expert identity
67. breadcrumb data
68. template-specific structured data
69. stable entity references
70. factual consistency across HTML/schema/data feeds

Google uses structured data to help understand page content, but structured data is not a guarantee of enhanced appearance. ([Google Developers][11])

For Google generative Search specifically, no new “AI schema” is required. ([Google Developers][3])

---

# Domain H — AEO / answer usability

71. concise extractable answer
72. atomic factual claims
73. evidence adjacent to claim
74. explicit provenance
75. original information gain
76. structured comparisons
77. limitations and conditions
78. genuine secondary questions
79. stable section anchors where useful
80. natural terminology variants

Preferred information pattern:

**Answer → evidence → explanation → conditions → source**

Do not force every page into this structure when it harms user intent.

---

# Domain I — GEO / generative-search controls

81. factual freshness
82. honest date/update signals
83. IndexNow assessment where relevant
84. OAI-SearchBot policy
85. GPTBot policy
86. Google snippet/AI preview controls
87. Bing cited-page coverage
88. Bing grounding-query analysis
89. agent/accessibility compatibility
90. unsupported GEO-mechanism review

Bing's AI Performance currently exposes:

- total citations;
- average cited pages;
- sampled grounding queries;
- page-level citation activity;
- visibility trends.

Microsoft explicitly cautions that citation counts do not represent ranking, authority, or answer placement. ([Bing Blogs][4])

OpenAI recommends ARIA labels, roles and states for interactive elements to improve agent understanding in Atlas. ([OpenAI Help Center][5])

---

# Domain J — Measurement and governance

91. Search Console verified
92. Bing Webmaster Tools verified
93. Google generative-AI baseline where reporting is available
94. Bing citation baseline
95. ChatGPT referral tracking
96. representative query/prompt set
97. repeat observations
98. multi-engine sampling
99. controlled experimentation
100.  business-outcome attribution

Google began rolling out separate generative-AI Search Console reporting in June 2026, reporting items such as impressions, pages, countries, devices and trends to an initial subset of sites. ([Google Developers][12])

OpenAI currently states that ChatGPT search referral links include `utm_source=chatgpt.com`, permitting direct referral tracking. ([OpenAI Help Center][5])

---

# 14. Audit gates

A single aggregate “SEO score” must not override mandatory controls.

## Gate 1 — Eligibility

No production program may be considered healthy while an unresolved P0 exists within:

**crawl → render → canonical → index**

Examples:

- robots block;
- unintended `noindex`;
- broken canonical template;
- sitewide rendering failure.

---

## Gate 2 — Retrieval readiness

Review:

- architecture;
- internal linking;
- semantic relevance;
- entity clarity;
- content uniqueness.

---

## Gate 3 — Answer/citation readiness

Review:

- evidence;
- source quality;
- extractability;
- original information;
- provenance;
- factual consistency.

---

## Gate 4 — Measurement maturity

Program must demonstrate:

- reliable first-party baseline;
- engine-specific measurement;
- meaningful evaluation windows;
- business-outcome interpretation.

---

# 15. Outcome, Measurement, and Control Model

The parent framework requires every material metric to define its purpose, unit of analysis, data source, baseline, thresholds, minimum evidence, owner, decision authority, and limitations.

The minimum registry for this SOP follows.

| ID       | Metric                         | Type            | Source                  | Primary decision         |
| -------- | ------------------------------ | --------------- | ----------------------- | ------------------------ |
| SEO-001  | Indexable canonical conformity | Guardrail       | crawler                 | Can deployment continue? |
| SEO-002  | Valid indexable `200` rate     | Guardrail       | crawler/logs            | Technical health         |
| SEO-003  | Organic indexed-page coverage  | Leading         | GSC/index checks        | Index diagnosis          |
| SEO-004  | Organic impressions            | Outcome/leading | GSC                     | Search visibility        |
| SEO-005  | Organic clicks                 | Outcome         | GSC                     | Traffic outcome          |
| SEO-006  | Organic qualified conversions  | Outcome         | analytics/CRM           | Business value           |
| SEO-007  | Critical crawl-error rate      | Guardrail       | logs/crawler            | Escalation               |
| GEO-001  | Google AI impressions          | Leading         | GSC, where available    | Google AI visibility     |
| GEO-002  | Bing total citations           | Leading         | Bing Webmaster          | Citation trend           |
| GEO-003  | Bing cited-page count          | Leading         | Bing Webmaster          | Content coverage         |
| GEO-004  | Grounding-query coverage       | Diagnostic      | Bing Webmaster          | Content opportunity      |
| GEO-005  | ChatGPT referral sessions      | Outcome/leading | analytics               | Discoverability          |
| AEO-001  | Answer-ready content coverage  | Process/quality | content audit           | Remediation              |
| AEO-002  | Evidence-backed claim coverage | Quality         | content audit           | Credibility              |
| EXP-001  | Experimental citation rate     | Experiment      | controlled prompt panel | GEO experiment           |
| DATA-001 | Measurement completeness       | Guardrail       | pipeline                | Data trust               |
| OPS-001  | P0 mean time to detection      | Guardrail       | issue system            | Operational control      |
| OPS-002  | P0 mean time to containment    | Guardrail       | issue system            | Operational control      |

---

# 16. Metric definitions

## SEO-001 — Indexable canonical conformity

**Formula**

`indexable URLs whose declared/linked/sitemap canonical signals agree ÷ sampled indexable URLs`

**Target:** ≥99% on strategic templates.

**Warning:** <99%.

**Stop/escalation:** material sitewide template defect or >5% unexpected disagreement in a newly deployed strategic cohort.

**Minimum evidence:** representative crawl sufficient to cover all affected templates.

---

## GEO-002 — Bing total citations

Use the value reported by Bing Webmaster Tools.

It must not be interpreted as:

- answer ranking;
- citation position;
- authority score;
- revenue;
- attribution to a particular prompt.

Microsoft specifically describes those limitations. ([Bing Blogs][4])

---

## EXP-001 — Experimental citation rate

**Formula**

`owned-citation appearances / valid engine-prompt observations`

Segment by:

- engine;
- prompt family;
- market;
- language;
- date;
- test condition.

Do not combine engine results into a universal score without preserving the segmentation.

---

# 17. Dashboard contract

Every dashboard panel must answer:

1. What decision does this support?
2. Who owns the decision?
3. How current is the evidence?
4. What uncertainty exists?
5. What happens when a threshold is crossed?

This is directly consistent with the uploaded SOP framework's dashboard standard.

Minimum dashboard sections:

**Technical health**
crawl/index/canonical/render

**Google Search**
organic + AI visibility where available

**Microsoft AI**
citations + cited pages + grounding queries

**OpenAI referrals**
ChatGPT-referred sessions and downstream outcomes

**Experiments**
prompt cohorts, variants and observation counts

**Business outcomes**
qualified traffic, leads, sales, revenue/assisted conversions

---

# 18. Start / continue / warning / pause / stop / rollback thresholds

The uploaded framework requires decision thresholds to specify condition, evaluation window, minimum evidence, authority, response time, action and re-entry condition.

## TH-SEO-001 — Start

A material SEO change may start only when:

- owner identified;
- affected URLs/templates defined;
- baseline recorded;
- crawl/index state known;
- rollback available where material;
- measurement active;
- test cohort identified where practical.

**Authority:** execution owner.

---

## TH-SEO-002 — Continue

Continue when:

- no P0 threshold breached;
- indexability/canonical guardrails remain normal;
- data quality is acceptable;
- outcome direction is neutral or positive within the agreed window.

---

## TH-SEO-003 — Warning

Trigger when, after a material deployment:

- strategic indexable URL count deviates unexpectedly by >2%;
- organic impressions decline >10% versus appropriate control/baseline without an identified external cause;
- crawler error rate materially increases;
- citation/AI visibility falls outside expected historical variation.

**Action:** investigate before expansion.

These values are **default operating parameters**, not claims from Google/Bing/OpenAI. They must be calibrated to the actual site's volatility and traffic.

---

## TH-SEO-004 — Pause

Pause expansion if:

- unexpected canonical behavior is detected;
- important rendered content disappears;
- data is insufficient to judge safety;
- a major engine-control change is ambiguous;
- measurement instrumentation fails during rollout.

---

## TH-SEO-005 — Stop / rollback

Immediate rollback consideration when a release produces:

- sitewide/major `noindex`;
- critical robots blocking;
- widespread `5xx`;
- wrong sitewide canonical;
- substantial loss of primary rendered content;
- catastrophic internal-link loss;
- material compliance/security violation.

**Authority:** SEO execution owner + engineering authority according to incident policy.

**Response:** immediate.

---

## TH-GEO-001 — GEO experiment expansion

Expand only if:

- minimum prompt/run sample has been satisfied;
- direction is positive against control/baseline;
- no technical SEO guardrail deteriorates;
- answer factuality remains acceptable;
- business/user-quality measures do not worsen materially.

---

# 19. Feedback requirements

| Event                               |           Maximum initial feedback latency | Recipient                        |
| ----------------------------------- | -----------------------------------------: | -------------------------------- |
| P0 sitewide indexing/crawl incident |                      Immediate / automated | SEO + engineering incident owner |
| Major rendering defect              |                    ≤1 hour after detection | Engineering + SEO                |
| Migration anomaly                   |                           Same working day | Migration owner                  |
| P1 audit issue                      |                           ≤2 business days | Relevant owner                   |
| Experiment result                   |     At end of predefined evaluation window | Improvement owner                |
| Monthly AI visibility review        |                                    Monthly | SEO/GEO owner                    |
| Platform-documentation change       | ≤5 business days after validated discovery | SOP owner                        |

Alert volume must remain decision-oriented rather than merely real time; this mirrors the parent framework's fast-feedback principles.

---

# 20. Execution evidence

Each material optimization/change should record, where applicable:

- execution/change ID;
- SOP version;
- date/time;
- owner;
- affected domain;
- affected URL set/template;
- pre-change crawl snapshot;
- baseline metrics;
- change description;
- deployment version;
- decision authority;
- thresholds;
- post-change crawl;
- GSC evidence;
- Bing evidence;
- analytics evidence;
- exceptions;
- rollback;
- final decision;
- learning.

---

# 21. Standard execution event schema

Recommended fields:

| Field               | Purpose                      |
| ------------------- | ---------------------------- |
| Event ID            | Unique event                 |
| Timestamp           | When change/event occurred   |
| Recorded timestamp  | When telemetry received      |
| Domain              | Property                     |
| URL/template ID     | Affected entity              |
| Release ID          | Code/content deployment      |
| Actor/role          | Responsible party            |
| Prior state         | Previous lifecycle state     |
| New state           | New lifecycle state          |
| Action              | What happened                |
| Threshold ID        | Relevant decision rule       |
| Evidence reference  | Crawl/report/dashboard       |
| Exception ID        | Related deviation            |
| Data-quality status | Valid/delayed/incomplete     |
| Decision            | Continue/pause/rollback/etc. |

This preserves the event-oriented instrumentation model in the uploaded framework.

---

# 22. Audit scoring

Use weighted scoring:

**P0 = 5 points**
**P1 = 3 points**
**P2 = 1 point**

Score:

`passed weighted points / applicable weighted points × 100`

But the overall score must be displayed together with:

### **OPEN P0 COUNT**

because aggregate scoring may not conceal blocker failures.

Report five maturity dimensions independently:

| Dimension                 | Target |
| ------------------------- | -----: |
| Technical eligibility     |   ≥95% |
| Retrieval readiness       |   ≥85% |
| Semantic/entity readiness |   ≥85% |
| Answer/citation readiness |   ≥80% |
| Measurement maturity      |   ≥80% |
| Open P0s                  |  **0** |

Targets must be baselined and formally approved for the specific organization before being used as hard automated controls.

---

# 23. Remediation backlog

Every finding must include:

- finding ID;
- affected check;
- priority;
- affected URLs/template;
- evidence;
- business/search risk;
- likely cause;
- recommended remediation;
- owner;
- estimated effort;
- reversibility;
- dependency;
- target sprint/date;
- validation method;
- status.

Sort primarily by:

**risk × reach × expected impact × confidence ÷ implementation cost**

while treating P0s as overrides.

---

# 24. Change classification

The source framework defines editorial, low-risk reversible, material, and emergency change classes.

Apply them to SEO as follows.

| Class                       | SEO/GEO examples                                                                                                   | Control                                                            |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------ |
| **A — Editorial**           | typo, broken internal link, copy clarification                                                                     | expedited                                                          |
| **B — Low-risk reversible** | title refinement, local internal-link module adjustment, answer-block experiment                                   | owner approval + monitoring                                        |
| **C — Material**            | URL architecture, canonical rules, rendering system, mass schema, large content template, faceted-navigation rules | formal review + pilot + rollback                                   |
| **D — Emergency**           | production noindex, robots catastrophe, wrong sitewide canonical, critical outage                                  | emergency authority + immediate containment + retrospective review |

Material changes must not be split artificially to avoid Class C controls.

---

# 25. Pilot and ramp

Class C changes should use:

**pilot → validate → ramp → steady state**

where technically feasible.

Before pilot:

- baseline recorded;
- cohort isolated;
- expected outcome defined;
- guardrails defined;
- test duration/sample defined;
- rollback tested;
- monitoring active.

During ramp:

- expand only after acceptance criteria;
- monitor technical guardrails more frequently;
- document every expansion decision.

---

# 26. GEO/AEO experimentation standard

Each experiment must define before launch:

- hypothesis;
- engine(s);
- query/prompt cohort;
- treatment;
- comparison;
- sample/run count;
- evaluation period;
- retrieval/citation measure;
- classic SEO guardrail;
- factual-quality guardrail;
- conversion/user guardrail;
- success threshold;
- stop threshold;
- decision authority.

Do not:

- select the winning threshold after observing results without disclosure;
- test only one hand-picked prompt;
- mix engines without segmentation;
- treat absence of citation as proof of non-retrieval;
- treat a citation as proof of causal conversion lift.

---

# 27. Content/AEO execution standard

For strategic answer-seeking pages:

1. Identify the primary entity/topic.
2. Identify the real user decision/question.
3. Provide a concise answer where appropriate.
4. Explain the answer.
5. Support material factual claims.
6. State important conditions.
7. Use tables/lists only when they improve comprehension.
8. Make dates, units, jurisdictions and versions explicit.
9. Link to appropriate primary evidence.
10. Add original information where possible.
11. Verify schema/content parity.
12. Update materially outdated information.

Do **not** manufacture dozens of near-identical pages solely for imagined AI prompt variations.

Google's 2026 generative-search guidance emphasizes valuable, unique, non-commodity content and continues to frame SEO fundamentals as foundational. ([Google Developers][13])

---

# 28. Crawler-policy standard

Crawler policy must be intentional and recorded.

Example decision register:

| Crawler       | Desired behavior                                | Owner          | Current status |
| ------------- | ----------------------------------------------- | -------------- | -------------- |
| Googlebot     | Allow strategic content                         | SEO            | [ ]            |
| Bingbot       | Allow strategic content                         | SEO            | [ ]            |
| OAI-SearchBot | Allow/deny according to ChatGPT Search strategy | SEO/legal      | [ ]            |
| GPTBot        | Separate training policy                        | Legal/data/SEO | [ ]            |

Do not assume that blocking one OpenAI crawler produces the same effect as blocking another. ([OpenAI Help Center][5])

---

# 29. Exceptions and degraded modes

## Search Console unavailable

Use:

- crawler;
- logs;
- analytics;
- cached historical GSC exports.

Do not make major performance conclusions until primary data resumes unless urgent technical evidence justifies action.

---

## Bing AI Performance unavailable

Record:

**data unavailable**

Do not substitute a third-party metric and label it as Bing citation data.

---

## Google generative-AI report unavailable

The June 2026 feature is being rolled out rather than universally available. If unavailable, retain ordinary Search Console data and other controlled observations without fabricating AI-specific GSC attribution. ([Google Developers][12])

---

## AI output is inconsistent

Increase:

- runs;
- prompt variants;
- observation window.

Do not average incompatible engines into a false deterministic ranking.

---

# 30. Data-quality controls

Critical metrics must be checked for:

- completeness;
- validity;
- freshness;
- duplication;
- consistent definitions;
- source lineage;
- version compatibility;
- segmentation;
- sampling changes.

A broken analytics implementation may not be interpreted as a real traffic decline without corroborating evidence.

---

# 31. Use of artificial intelligence

AI may assist with:

- crawl analysis;
- pattern detection;
- log summarization;
- content-gap discovery;
- entity extraction;
- structured-data review;
- query clustering;
- draft remediation;
- monitoring;
- prompt testing;
- evidence organization.

AI output must not independently:

- alter sitewide robots controls;
- deploy `noindex`;
- alter canonical rules;
- perform an irreversible migration;
- approve a Class C change;
- declare an experiment successful;
- publish unverified factual claims;
- modify production thresholds without authorization.

This follows the uploaded parent SOP's explicit rule that AI-generated material is not authoritative and must be verified by qualified reviewers.

---

# 32. Training

Relevant users must understand:

- crawl/index fundamentals;
- robots vs `noindex`;
- canonicalization;
- sitemap behavior;
- rendering;
- structured-data integrity;
- analytics limitations;
- GEO vs classic SEO;
- citation vs retrieval;
- platform-specific crawler controls;
- change classes;
- rollback authority.

Content teams additionally require:

- source evaluation;
- evidence attribution;
- entity clarity;
- answer design;
- freshness management.

---

# 33. Steady-state control cadence

## Daily / automated

Monitor:

- outages;
- `5xx`;
- robots changes;
- major index directives;
- deployment anomalies;
- critical template regressions.

## Weekly

Review:

- crawl errors;
- index anomalies;
- canonical changes;
- key template health;
- P0/P1 backlog;
- major deployments.

## Monthly

Review:

- Google organic performance;
- Google AI reporting where available;
- Bing AI citations;
- grounding-query opportunities;
- ChatGPT referrals;
- answer-ready content;
- experiment status;
- business outcomes.

## Quarterly

Review:

- architecture;
- programmatic index footprint;
- crawler policies;
- information-gain strategy;
- measurement definitions;
- SOP effectiveness.

## Event-triggered

Immediate review after:

- migration;
- redesign;
- CMS change;
- crawler-policy change;
- rendering architecture change;
- search-engine policy change;
- major algorithm/search-product change where material evidence exists.

---

# 34. Lifecycle review

At each lifecycle review, decide:

**continue unchanged**
**optimize**
**revise**
**pivot**
**suspend**
**replace**
**consolidate**
**retire**

A review decision should be recorded even when no change is made, matching the source framework.

---

# 35. SOP success measures

Measure the SOP itself, not just SEO performance.

### Outcome quality

- % strategic properties with zero open P0s;
- % material releases with baseline and rollback;
- % significant findings with verified closure.

### Feedback performance

- mean P0 detection latency;
- mean containment latency;
- % P0s detected before material index impact.

### Change performance

- % Class C changes piloted;
- rollback rate;
- change lead time;
- % experiments with predeclared threshold.

### Data quality

- % critical metrics passing quality checks.

### Human usability

- analyst time to identify applicable control;
- undocumented-workaround frequency;
- alert burden;
- remediation backlog age.

---

# 36. Records

Retain, according to organizational retention policy:

- audit outputs;
- crawler snapshots;
- robots snapshots;
- sitemap records;
- index evidence;
- rendered-page evidence;
- structured-data tests;
- deployment/change records;
- metric definitions;
- dashboards;
- pilot plans;
- experiment results;
- rollback records;
- approval records;
- deviations;
- lifecycle decisions.

---

# 37. References

### Internal controlling source

**SOP Lifecycle and Control Framework — SOP-QMS-001 v2.0**

### Current external authoritative sources

Google — AI features and website eligibility. ([Google Developers][1])

Google — generative AI optimization guidance. ([Google Developers][13])

Google — canonicalization. ([Google Developers][7])

Google — `noindex` controls. ([Google Developers][6])

Google — JavaScript SEO. ([Google Developers][10])

Google — sitemap requirements. ([Google Developers][8])

Google — crawlable links. ([Google Developers][9])

Google — generative-AI Search Console reporting. ([Google Developers][12])

Microsoft — Bing Webmaster Tools AI Performance. ([Bing Blogs][4])

OpenAI — publisher/developer crawler and referral guidance. ([OpenAI Help Center][5])

---

# Appendix A — Operational checklist

The **100 checks in Sections 13A–13J are the controlled audit checklist**.

Every execution record should contain:

| Field                | Required |
| -------------------- | :------: |
| Check ID             |    ✓     |
| Applicable           |    ✓     |
| Status: Pass/Fail/NA |    ✓     |
| P0/P1/P2             |    ✓     |
| Evidence             |    ✓     |
| Example URL(s)       |    ✓     |
| Owner                |    ✓     |
| Recommended action   |    ✓     |
| Expected effect      |    ✓     |
| Effort               |    ✓     |
| Target date          |    ✓     |
| Validation evidence  |    ✓     |
| Closed date          |    ✓     |

---

# Appendix B — Recommended finding format

**Finding:** SEO-014
**Check:** Canonical signal alignment
**Priority:** P0
**Scope:** Product template
**Evidence:** 18,241 URLs sitemap-listed as canonical while HTML canonical points to category root.
**Expected effect:** Incorrect clustering/index selection.
**Action:** Correct template canonical logic; regenerate sitemap; verify internal links.
**Owner:** Engineering
**Change class:** C
**Rollback:** Restore prior template build.
**Validation:** crawl + rendered HTML + URL inspection sample.
**Decision:** [Open / Implement / Validate / Close]

That is the level of evidence expected for a material finding.

---

# Appendix C — GEO experiment record

**Experiment ID:** GEO-EXP-[000]

**Hypothesis:**
[Specific content/evidence change] will increase [retrieval/citation outcome] for [prompt family] without reducing [SEO/quality guardrail].

**Engines:**
[Google/Bing/ChatGPT/other]

**Prompt cohort:**
[Defined]

**Treatment URLs:**
[Defined]

**Control URLs/cohort:**
[Defined]

**Minimum observations:**
[Defined before test]

**Primary outcome:**
[Defined]

**Guardrails:**
[Defined]

**Start threshold:**
[Defined]

**Success threshold:**
[Defined]

**Stop threshold:**
[Defined]

**Decision:**
Expand / continue / modify / rollback / reject.

---

# Appendix D — Practical operating model

The production stack should be treated as one system:

**Technical SEO**
makes information technically eligible and discoverable.

↓

**Information architecture / semantics**
make it retrievable and understandable.

↓

**AEO**
makes answers explicit, defensible and usable.

↓

**GEO**
measures and improves participation in retrieval-grounded generative systems.

↓

**Analytics / business measurement**
determines whether visibility produces value.

The program therefore should **not** maintain separate contradictory “SEO content” and “AI content.”

The controlled source should be a single, accurate, useful information system exposed appropriately to multiple retrieval surfaces.

---

## Approval readiness

Before this SOP should move from **Draft for Review → Approved**, I would require five things:

1. Replace the generic role placeholders with named organizational roles.
2. Calibrate the default numerical warning thresholds against the site's real historical volatility.
3. Map each of the 100 controls to the actual tools/data sources available.
4. Run the SOP once against one representative site or business unit.
5. Validate that rollback and P0 incident paths actually work.

Those requirements are consistent with the uploaded framework, which requires metric precision, minimum evidence, threshold-action mappings, tested instrumentation, intended-user validation, and piloting before a controlled SOP is treated as operationally complete.

Given how quickly Google, Bing and OpenAI search controls/reporting are changing, I would set the **external technical-reference refresh cadence to monthly**, while allowing stable crawl/canonical controls to change only when evidence warrants it.

[1]: https://developers.google.com/search/docs/appearance/ai-features?kgs=aa0bcc3d152ed142&utm_source=chatgpt.com 'AI Features and Your Website | Google Search Central  |  Documentation  |  Google for Developers'
[2]: https://developers.google.com/search/docs/appearance/ai-features?hl=es&utm_source=chatgpt.com 'Funciones de IA y tu sitio web | Centro de la Búsqueda de Google  |  Documentation  |  Google for Developers'
[3]: https://developers.google.com/search/docs/appearance/ai-features?hl=es-419&utm_source=chatgpt.com 'Funciones potenciadas por IA y tu sitio web | Central de la Búsqueda de Google  |  Documentation  |  Google for Developers'
[4]: https://blogs.bing.com/webmaster/February-2026/Introducing-AI-Performance-in-Bing-Webmaster-Tools-Public-Preview?utm_source=chatgpt.com 'Introducing AI Performance in Bing Webmaster Tools Public Preview ...'
[5]: https://help.openai.com/en/articles/12627856-publishers-and-developers-faq?utm_source=chatgpt.com 'Publishers and Developers - FAQ | OpenAI Help Center'
[6]: https://developers.google.com/search/docs/crawling-indexing/block-indexing?utm_source=chatgpt.com 'Block Search Indexing with noindex | Google Search Central  |  Documentation  |  Google for Developers'

[7]: https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls?utm_source=chatgpt.com "How to Specify a Canonical with rel=\"canonical\" and Other Methods | Google Search Central  |  Documentation  |  Google for Developers"
[8]: https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap?hl=en&utm_source=chatgpt.com "Build and Submit a Sitemap | Google Search Central  |  Documentation  |  Google for Developers"
[9]: https://developers.google.com/search/docs/crawling-indexing/links-crawlable?authuser=2&utm_source=chatgpt.com "SEO Link Best Practices for Google | Google Search Central  |  Documentation  |  Google for Developers"
[10]: https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics?authuser=7&utm_source=chatgpt.com "Understand JavaScript SEO Basics | Google Search Central  |  Documentation  |  Google for Developers"
[11]: https://developers.google.com/search/docs/appearance?utm_source=chatgpt.com "Google Search Appearance | Google Search Central  |  Documentation  |  Google for Developers"
[12]: https://developers.google.com/search/blog/2026/06/gen-ai-performance-reports?hl=en&utm_source=chatgpt.com "Introducing Search Generative AI performance reports in Search Console  |  Google Search Central Blog  |  Google for Developers"
[13]: https://developers.google.com/search/blog/2026/05/a-new-resource-for-optimizing?utm_source=chatgpt.com "A new resource for optimizing for generative AI in Google Search  |  Google Search Central Blog  |  Google for Developers"
