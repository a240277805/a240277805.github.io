---
title:
---
# Easy Rule
## 使用方式

## 几种通用的rule
### ActivationRuleGroup
多个rule 只有一个 rule匹配则 action
```aidl
    @Override
    public boolean evaluate(Facts facts) {
        for (Rule rule : rules) {
            if (rule.evaluate(facts)) {
                selectedRule = rule;
                return true;
            }
        }
        return false;
    }

    @Override
    public void execute(Facts facts) throws Exception {
        if (selectedRule != null) {
            selectedRule.execute(facts);
        }
    }
```
### ConditionalRuleGroup
获取一个最高priority 的 作为 condition ,它命中，才进行下边的规则匹配

```aidl
 @Override
    public boolean evaluate(Facts facts) {
        successfulEvaluations = new HashSet<>();
        conditionalRule = getRuleWithHighestPriority();
        if (conditionalRule.evaluate(facts)) {
            for (Rule rule : rules) {
                if (rule != conditionalRule && rule.evaluate(facts)) {
                    successfulEvaluations.add(rule);
                }
            }
            return true;
        }
        return false;
    }
    @Override
    public void execute(Facts facts) throws Exception {
        conditionalRule.execute(facts);
        for (Rule rule : sort(successfulEvaluations)) {
            rule.execute(facts);
        }
    }
    private Rule getRuleWithHighestPriority() {
        List<Rule> copy = sort(rules);
        // make sure we only have one rule with the highest priority
        Rule highest = copy.get(0);
        if (copy.size() > 1 && copy.get(1).getPriority() == highest.getPriority()) {
           throw new IllegalArgumentException("Only one rule can have highest priority");
        }
        return highest;
    }
```
### UnitRuleGroup
匹配所有的rules  所有的都成功才会执行 rule 的action
```aidl
@Override
    public boolean evaluate(Facts facts) {
        if (!rules.isEmpty()) {
            for (Rule rule : rules) {
                if (!rule.evaluate(facts)) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    @Override
    public void execute(Facts facts) throws Exception {
        for (Rule rule : rules) {
            rule.execute(facts);
        }
    }
```