#!/usr/bin/env npx tsx

interface HookInput {
  session_id: string;
  transcript_path: string;
  cwd: string;
  allowed_tools: string[];
  prompt: string;
}

interface SkillTrigger {
  keywords: string[];
  intent_patterns: string[];
  file_patterns?: string[];
}

interface SkillRule {
  name: string;
  path: string;
  description: string;
  triggers: SkillTrigger;
  priority: "critical" | "high" | "medium" | "low";
}

interface SkillRules {
  version: string;
  skills: SkillRule[];
}

interface MatchedSkill {
  skill: SkillRule;
  matchType: "keyword" | "intent" | "file";
  matchedTerm: string;
}

async function main(): Promise<void> {
  try {
    let inputData = "";
    for await (const chunk of process.stdin) {
      inputData += chunk;
    }

    if (!inputData.trim()) {
      process.exit(0);
    }

    const input: HookInput = JSON.parse(inputData);
    const prompt = input.prompt.toLowerCase();

    // Load skill rules
    const fs = await import("fs/promises");
    const path = await import("path");

    const skillRulesPath = path.join(
      process.env.CLAUDE_PROJECT_DIR || process.cwd(),
      ".claude",
      "skills",
      "skill-rules.json"
    );

    let skillRules: SkillRules;
    try {
      const rulesContent = await fs.readFile(skillRulesPath, "utf-8");
      skillRules = JSON.parse(rulesContent);
    } catch {
      // No skill rules configured, exit silently
      process.exit(0);
    }

    const matchedSkills: MatchedSkill[] = [];

    for (const skill of skillRules.skills) {
      // Check keyword matches
      for (const keyword of skill.triggers.keywords) {
        if (prompt.includes(keyword.toLowerCase())) {
          matchedSkills.push({
            skill,
            matchType: "keyword",
            matchedTerm: keyword,
          });
          break;
        }
      }

      // Check intent pattern matches
      for (const pattern of skill.triggers.intent_patterns) {
        try {
          const regex = new RegExp(pattern, "i");
          if (regex.test(prompt)) {
            // Avoid duplicates
            if (!matchedSkills.find((m) => m.skill.name === skill.name)) {
              matchedSkills.push({
                skill,
                matchType: "intent",
                matchedTerm: pattern,
              });
            }
            break;
          }
        } catch {
          // Invalid regex, skip
        }
      }
    }

    if (matchedSkills.length === 0) {
      process.exit(0);
    }

    // Group by priority
    const priorityOrder = ["critical", "high", "medium", "low"];
    const grouped = new Map<string, MatchedSkill[]>();

    for (const priority of priorityOrder) {
      grouped.set(priority, []);
    }

    for (const match of matchedSkills) {
      const priority = match.skill.priority;
      grouped.get(priority)?.push(match);
    }

    // Format output
    const output: string[] = [];
    output.push("");
    output.push("---");
    output.push("SKILL SUGGESTIONS");
    output.push("---");

    const icons: Record<string, string> = {
      critical: "[!]",
      high: "[*]",
      medium: "[+]",
      low: "[i]",
    };

    for (const priority of priorityOrder) {
      const skills = grouped.get(priority) || [];
      if (skills.length > 0) {
        output.push("");
        output.push(`${icons[priority]} ${priority.toUpperCase()} PRIORITY:`);
        for (const match of skills) {
          output.push(`   - ${match.skill.name}: ${match.skill.description}`);
          output.push(`     Path: ${match.skill.path}`);
          output.push(`     Matched: ${match.matchType} "${match.matchedTerm}"`);
        }
      }
    }

    output.push("");
    output.push("Consider invoking the Skill tool with the suggested skill names.");
    output.push("---");

    console.log(output.join("\n"));
  } catch (error) {
    // Silently exit on errors to not disrupt workflow
    process.exit(0);
  }
}

main();
