# Платформа «Матрёшка.Аудит» (MatryoshkaAudit)

> **Суверенная аналитическая платформа сквозного аудита цепочек поставок, O-Ring устойчивости и нормативного соответствия ПП РФ № 719 для отечественного машиностроения.**
> 
> Разработано в рамках магистерской диссертации ВЭД (Лестех / Минпромторг РФ).
> Организация на GitHub: [https://github.com/orgs/MatryoshkaAudit](https://github.com/orgs/MatryoshkaAudit)

---

## 1. Архитектура микросервисов

Архитектурный шаблон спроектирован по образцу enterprise-экосистем (в стиле `IPKService`):

| Репозиторий | Стек / Технологии | Назначение | Порты |
|---|---|---|---|
| [`protos`](https://github.com/MatryoshkaAudit/protos) | Protocol Buffers, gRPC, Pydantic v2 | Контракты взаимодействия (BOM, Policy, Audit, Analytics), скомпилированные Python-стабы и DTO | — |
| [`database`](https://github.com/MatryoshkaAudit/database) | SQLAlchemy 2.0 (asyncpg), PostgreSQL 16, Alembic | Транзакционные модели БД (OLTP), сид-данные эталонного кейса Харвестера ЛХ-4 | `5433` (внутри `5432`) |
| [`enterprise-service`](https://github.com/MatryoshkaAudit/enterprise-service) | FastAPI, gRPC, Python 3.10+ | Кабинет предприятия: многоуровневый граф BOM (Tier 1-3), детекция O-Ring уязвимостей, каталог аналогов | `8001` (REST), `50051` (gRPC) |
| [`regulator-service`](https://github.com/MatryoshkaAudit/regulator-service) | FastAPI, gRPC, OpenRouter AI, Python 3.10+ | Ситуационный центр: оценка по ПП РФ № 719, симулятор санкционных шоков, ИИ-сценарии, цифровая ЭЦП | `8002` (REST), `50052` (gRPC) |
| [`analytics-service`](https://github.com/MatryoshkaAudit/analytics-service) | FastAPI, gRPC, ClickHouse, Redis | Аналитическое ядро OLAP: неизменяемый реестр решений, стохастическое моделирование Монте-Карло, временные ряды | `8003` (REST), `50053` (gRPC), `8123` (CH) |
| [`frontend`](https://github.com/MatryoshkaAudit/frontend) | React 18, TypeScript, Vite, Tailwind CSS, Lucide | Трехпортальный клиент: Кабинет Завода, Ситуационный Центр и ClickHouse OLAP Аналитика. Anti-AI-slop | `3000` |

---

## 2. Ключевые математические модели

### 2.1. Формула реальной локализации (De Facto Localization)
В отличие от поверхностной оценки первого уровня (где агрегат с импортной начинкой объявляется «российским»), платформа рассчитывает сквозной суверенный вес по листовым узлам:

$$\text{Loc}_{de\_facto} = \sum_{i \in \text{Leaves}} \left[ \frac{\text{Cost}_i}{\text{TotalCost}} \times (1 - \text{Risk}(\text{Country}_i)) \right] \times 100\%$$

Где:
- $\text{Risk}(\text{Country}_i) \in [0.0; 1.0]$: страновой риск юрисдикции поставщика (РФ/ЕАЭС = 0.0, нейтральные = 0.3, ЕС/G7 = 0.95–1.0).

### 2.2. Индекс критического отказа O-Ring (Critical Failure Index)
Базируется на теории Майкла Кремера (Kremer's O-Ring Theory, 1993):

$$\text{CFI}_i = \text{Criticality}_i \times \text{Risk}(\text{Country}_i) \times (1 - \text{AnalogAvail}_i)$$

- $\text{Criticality}_i$: важность узла для работы машины (1.0 = критический узел).
- $\text{AnalogAvail}_i$: доступность пин-ту-пин аналогов (1.0 = есть на складе в РФ, 0.7 = требует редизайна, 0.0 = прямого аналога нет).
- При $\text{CFI}_i \ge 0.8$ узел признаётся **Chokepoint (узким горлышком)**.

### 2.3. «Парадокс копеечного чипа»
Кейс Харвестера ЛХ-4:
- Общая стоимость машины: **45 000 000 ₽**.
- Формальная локализация ПП РФ № 719: **88.5% (78 баллов — ПРОЙДЕНО)**.
- Микроконтроллер STM32F407VGT6: стоимость **1 850 ₽** (~0.004% от цены машины).
- Реальная де-факто локализация: **41.2%**.
- При санкционном шоке вероятность паралича конвейера составляет **98.5%**, так как без чипа пропорциональный гидроблок не может управлять пильной шиной.

---

## 3. Быстрый запуск

### Запуск всей экосистемы через Docker Compose

```bash
# 1. Склонировать окружение
cd MatryoshkaAudit

# 2. Настроить переменные окружения
cp .env.example .env

# 3. Поднять все сервисы (PostgreSQL, Redis, Enterprise, Regulator, Frontend)
docker compose up -d

# 4. Проверить работу интерфейса
open http://localhost:3000
```

### Локальный запуск и тестирование без Docker

```bash
# Запуск тестов бэкенда
make test

# Запуск сборки фронтенда
make build-frontend
```

---

## 4. Безопасность и регламент Zero Secrets
- Все API-ключи (включая OpenRouter) хранятся исключительно в файле `.env` локально и добавлены в `.gitignore`.
- Ни один ключ или пароль базы данных не коммитится в публичные или приватные репозитории GitHub.
- Валидация входных данных обеспечена схемами Pydantic v2.
- Защита от prompt-инъекций и детерминированный fallback в ИИ-пайплайне гарантируют непрерывность работы регуляторного контура.
