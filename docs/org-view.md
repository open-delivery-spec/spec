---
title: Organization-wide View
nav_order: 6
---

# Organization-wide View

**How much of our delivery is AI-assisted, across every repository, by tool,
trending which way?**

`ods report` answers that for one repository. The organization view is the
same numbers summed across all of them, produced by one scheduled workflow
that needs no setup in the repositories it covers and no service outside your
GitHub account.

## What you get

- **A dashboard** (`index.html`): AI commit share and AI line share across
  the organization, how many repositories show AI-assisted work, the trend
  over time, the per-tool breakdown, and a per-repository table sorted by AI
  share.
- **A job summary** on every run, as Markdown you can paste into a README or
  a quarterly report.
- **`org-report.json`** for anything downstream (a spreadsheet, a BI tool),
  next to the per-repository JSON it was merged from.
- Optionally, the dashboard on **GitHub Pages** at a stable URL.

The report contains commit counts, changed-line counts, tool names and
repository names. No code and no author names leave the runner.

## How it works

```text
schedule ──▶ org-ai-report.yml   (reusable workflow, runs in one repository you choose)
               │
               ├─ discover repositories (gh api) or take the list you give it
               ├─ for each repository:
               │    partial clone: every commit, only the blobs the window's diffs need
               │    ods report --since "90 days ago" --repo owner/name --json
               └─ ods report merge reports/*.json ──▶ index.html · summary.md · org-report.json
                                                        │
                                          artifact · job summary · GitHub Pages (optional)
```

Attribution is the same everywhere in ODS: the `Co-Authored-By` and
`Assisted-by` trailers AI tools emit, plus git-ai notes where present. It is
what the tools disclose, not forensic detection.

## Set it up

1. Pick a repository to host the report: an existing `.github` repository, or
   a new `ods-report` one.
2. Add a workflow that calls the reusable one on a schedule:

{% raw %}
```yaml
# .github/workflows/ai-report.yml
name: AI attribution report
on:
  schedule:
    - cron: "0 6 * * 1"   # Mondays, 06:00 UTC
  workflow_dispatch:

jobs:
  ai-report:
    uses: open-delivery-spec/.github/.github/workflows/org-ai-report.yml@main
    permissions:
      contents: read
      pages: write      # only with deploy-pages: true
      id-token: write   # only with deploy-pages: true
    with:
      org: your-org                 # optional (defaults to this repository's owner);
                                    # or repos: | with one owner/name per line
      since: "90 days ago"
      deploy-pages: true
    secrets:
      token: ${{ secrets.ODS_ORG_READ_TOKEN }}   # private repositories; omit for public ones
```
{% endraw %}

3. **Private repositories**: create a fine-grained personal access token (or a
   GitHub App token) with *Contents: read* on the repositories to cover and
   store it as `ODS_ORG_READ_TOKEN`. Without it the workflow's own token reads
   public repositories and the hosting repository only; the others are skipped
   with a warning, and the summary says how many.
4. **GitHub Pages**: in the hosting repository, Settings → Pages → Source:
   GitHub Actions. The run prints the dashboard URL.

The ODS organization runs the workflow on itself; the latest run, with its
artifact and job summary, is on the
[workflow page](https://github.com/open-delivery-spec/.github/actions/workflows/org-ai-report.yml).

| Input | Default | Meaning |
|---|---|---|
| `org` | owner of the calling repository | Organization or user whose repositories to cover. Archived repositories and forks are skipped. |
| `repos` | | Explicit list instead, one `owner/name` per line. |
| `since` | `90 days ago` | History window, any git `--since` expression. |
| `cli-ref` | `main` | ODS CLI version, tag or commit to install. |
| `deploy-pages` | `false` | Publish `index.html` to the hosting repository's Pages. |
| `artifact-name` | `ods-org-report` | Name of the uploaded artifact. |

## Reading the numbers

- **AI commit share** is the fraction of non-merge commits carrying an AI
  attribution; **AI line share** weights them by changed lines. A few large
  AI-assisted commits can make the second much higher than the first.
- **A repository at 0% AI** means nobody's tool added a trailer there. That is
  "no AI use" or "no disclosure", and the report cannot tell which. The
  [Open-Source AI Policy](oss-ai-policy.md) nudge on each pull request is what
  closes that gap over time.
- **Squash merges can erase the attribution.** The trailers live in the
  commit message, and a squash merge writes a new one. GitHub keeps them only
  when the squash message includes the commit details ("Default message" or
  "Default to pull request title and commit details" under Settings → General
  → Pull Requests); "Default to pull request title" and "… title and
  description" produce a commit with no trailer at all, so a pull request that
  was disclosed and checked lands on `main` as a human commit. Rebase and merge
  commits keep the original commits and need no setting. This report scans
  merged history, so that one setting decides whether the organization view
  sees the AI work at all; check it with `git log -1 --format=%B` after the
  next merge.
- **Trend granularity** is weekly for windows up to about six months and
  monthly beyond; when repositories with different spans are merged, weekly
  buckets are rolled up to months.
- **Cost**: partial clones fetch commit metadata and only the blobs the
  window's diffs touch. A 90-day window over a few dozen repositories runs in
  minutes on a standard runner.

## Without GitHub Actions

The merge reads only report files, so any CI can produce the view: run
`ods report --since "90 days ago" --repo owner/name --json` in each
repository, collect the files, and run `ods report merge` anywhere:

```bash
ods report merge reports/*.json --html index.html --markdown summary.md --json > org-report.json
```

A GitLab pipeline, a Jenkins job or a laptop loop over `git clone
--filter=blob:none` does the same as the workflow above.

## Grouping by team

The per-repository table is the unit today. To see teams, merge the subsets
you care about: `ods report merge reports/platform__*.json` gives the platform
team's view, and the organization run is the merge of everything. A team
mapping input is on the roadmap.
