# CSCI3100-Project Group 9
# CUMarket — CUHK Second-Hand Marketplace SaaS

## To Start Dev
```
bundle install
bin/rails generate migration EnablePgSearchForListings
bin/rails db:create db:migrate
bundle exec rspec
bundle exec cucumber
bin/rails server

```


## Overview
CUSHMS is a CUHK-focused second-hand marketplace for students to buy/sell items (textbooks, furniture, daily goods).
Key workflows: Listings + search/filtering + item status (Available → Reserved → Sold) + real-time chat/notifications.


## Project Scope
CUSHMS focuses on a safer campus-only marketplace:
- Only CUHK students can register (email domain restricted to `@link.cuhk.edu.hk`)
- Centralized listings for common campus needs (textbooks, electronics, dorm essentials)
- Faster discovery via search/filtering (with fuzzy search as an enhancement)
- Lower friction communication via real-time chat and notifications

  
## Demo Video

## Project Proposal
https://docs.google.com/document/d/1pZFI09Xlm_pA6fKjwJcew4SsQhj_CRPV6WBCmB0rNFI/edit?usp=sharing

## Live Demo
Walking Skeleton (Heroku): https://csci3100-group9-project-c5b9f4042600.herokuapp.com/


## Features

### Core
- Community / college space
- Listings workflow (CRUD)
- Item status management: **Available → Reserved → Sold**
- Search & filtering for listings
- Image upload for listings
- Real-time chat & notifications (ActionCable)

### Advanced (N-1)
- Fuzzy search + filtering
- CUHK email verification (restricted to `@link.cuhk.edu.hk`)
- Interactive dashboard (e.g., views/clicks)

## Tech Stack
- Ruby on Rails 7+
- Database: PostgreSQL
- Testing: RSpec (unit) + Cucumber (BDD)
- CI: GitHub Actions
- Deployment: Heroku

### Pages
- login page
- homepage (listed items + search function + filter function)
- community page
- chatpage 
- search result page
- profile

## Feature Ownership

Primary = main implementer. Secondary = support/reviewer + contributed commits/tests.

| Feature Name | Primary Developer | Secondary Developer | Notes |
| --- | --- | --- | --- |
| Project skeleton + repo setup | Au Chi Hin | Lau Chi Ho | Rails 7 init, initial structure. |
| Deployment (Heroku) | Lau Chi Ho |  | Heroku config + deploy steps. |
| CI pipeline (GitHub Actions) | Au Chi Hin | Tam Yiu Hei | Run RSpec + Cucumber in CI. |
| User auth + roles | Tam Yiu Hei |  | Auth + authorization boundaries. |
| User Profile | Tam Yiu Hei |  | User Profile for edit info |
| CUHK email verification (@link.cuhk.edu.hk) | Tam Yiu Hei |  | Domain restriction + verification flow. |
| Listings CRUD | Au Chi Hin |  | Create/edit/delete listings + validations. |
| Image uploads | Au Chi Hin |  | Active Storage (or equivalent). |
| Item status workflow |  |  | Available → Reserved → Sold. |
| Search & filtering | Lau Yat Laam |  | Keyword search + filters + fuzzy search. |
| Community/college feature |  |  | College grouping/community space. |
| ActionCable chat/notifications |  |  | Real-time messaging + notifications. |
| RSpec + SimpleCov |  |  | Unit tests + coverage evidence. |
| Cucumber BDD scenarios |  |  | Acceptance tests for key user stories. |



## Getting Started (Local)

### Prerequisites
- Ruby: see `.ruby-version` (recommended) or `ruby` version declared in `Gemfile`
- Bundler
- PostgreSQL (running locally)
- Node.js (only if your app uses JS tooling; depends on your Rails setup)

### Installation
```bash
git clone [<REPO_URL>](https://github.com/CSCI3100-Project-Group-9/CSCI3100-Project-Group-9.git)
cd CSCI3100-Project-Group-9
bundle install
bin/rails generate migration EnablePgSearchForListings
bin/rails db:create db:migrate
bin/rails server

