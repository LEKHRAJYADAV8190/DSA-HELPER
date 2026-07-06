const String noteTemplate = '''## Pattern


## Core Idea


## Algorithm


## Pseudo Code
```
```

## Time Complexity


## Space Complexity


## Mistakes I Made


## Important Edge Cases


## Interview Tricks


## Revision Summary


## Confidence
0
''';

abstract final class NoteSections {
  static const pattern = 'Pattern';
  static const coreIdea = 'Core Idea';
  static const algorithm = 'Algorithm';
  static const pseudoCode = 'Pseudo Code';
  static const timeComplexity = 'Time Complexity';
  static const spaceComplexity = 'Space Complexity';
  static const mistakes = 'Mistakes I Made';
  static const edgeCases = 'Important Edge Cases';
  static const interviewTricks = 'Interview Tricks';
  static const revisionSummary = 'Revision Summary';
  static const confidence = 'Confidence';
}

String emptyNoteFromTemplate() => noteTemplate;
