# Question Banks

Each section has a bank at `sections/section-0X0/quiz.yaml` with 10 questions, and
the course ends with `sections/final-domain-quiz.yaml`. Every bank uses schema
version 1 and the contract in `schemas/question-bank.schema.json`. `astrona.yaml`
lists each bank as a `type: quiz` entry with `pass_score: 70`; the section quiz
follows the section capstone lab.

## Fields And Rendering

- `id`: stable bank or question identity; preserve it when editing wording.
- `scope`: section or domain.
- `learning_objective`: the measurable outcome checked by the question.
- `source_readings`: author traceability to the teaching; not learner navigation.
- `prompt`: learner-visible question text.
- `options`: stable option IDs, answer text and per-option feedback.
- `correct_option`: the ID of the single correct option.
- `explanation`: feedback reinforcing the supported answer.

Match answers by option ID, not display position. The banks contain answer keys
and are public learning material, so this is not a secure examination bank. Do
not treat scores as an official OTCA result.

The files `assessments/index.yaml` and `assessments/domain-review.yaml` belong to
the earlier reading-only layout and are no longer registered.
