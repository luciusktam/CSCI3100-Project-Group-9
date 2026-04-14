# CSCI3100-Project Group 9
# CUMarket — CUHK Second-Hand Marketplace SaaS


## Overview
CUMarket is a CUHK-focused second-hand marketplace for students to buy/sell items (textbooks, furniture, daily goods).
Key workflows: Listings + search/filtering + item status (Available → Reserved → Sold) + real-time chat/notifications.


## Project Scope
CUMarket focuses on a safer campus-only marketplace:
- Only CUHK students can register (email domain restricted to `@link.cuhk.edu.hk`)
- Centralized listings for common campus needs (textbooks, electronics, dorm essentials)
- Faster discovery via search/filtering (with fuzzy search as an enhancement)
- Lower friction communication via real-time chat and notifications


## Demo Video
https://drive.google.com/file/d/1x9IBHuQ20HOSNvihqyCJx6Pg8jX86SUR/view?usp=sharing

## Project Proposal
https://docs.google.com/document/d/1pZFI09Xlm_pA6fKjwJcew4SsQhj_CRPV6WBCmB0rNFI/edit?usp=sharing

## Live Demo (Heroku)
https://csci3100-group9-project-c5b9f4042600.herokuapp.com/


## Features

### Core
- Community / college space
- Listings workflow (CRUD)
- Item status management: **Available → Reserved → Sold**
- Search & filtering for listings (keyword + fuzzy match)
- Image upload for listings
- Real-time chat & notifications (ActionCable)

### Advanced
- CUHK email verification (restricted to `@link.cuhk.edu.hk`) with **24-hour token expiry** (anti-Gmail-preload security)
- User banning / suspension (admin-controlled, time-limited)
- Admin dashboard (user management + content moderation)
- Fuzzy search + filtering

## Tech Stack
- Ruby on Rails 8.1
- Database: PostgreSQL + Redis (Upstash in production)
- Cache: Redis `:redis_cache_store`
- Real-time: ActionCable over Redis pub/sub
- Testing: RSpec (unit) + Cucumber (BDD)
- CI: GitHub Actions
- Deployment: Heroku

### Pages
- Login / Register page
- Homepage (listed items + search function + filter function)
- Community page (posts + comments)
- Chat page (real-time messaging)
- Listing page (search results + view all)
- Profile page
- Admin dashboard

## Feature Ownership

Primary = main implementer.
Secondary = support / reviewer + contributed commits / tests.

| Feature Name | Primary Developer | Secondary Developer | Notes |
| --- | --- | --- | --- |
| Project skeleton + repo setup | Au Chi Hin | Lau Chi Ho | Rails 8 init, initial structure. |
| Deployment (Heroku) | Lau Chi Ho | | Heroku config + deploy steps. |
| CI pipeline (GitHub Actions) | Au Chi Hin | Tam Yiu Hei | Run RSpec + Cucumber in CI. |
| User auth + roles | Tam Yiu Hei | | Auth + authorization boundaries. |
| User Profile | Tam Yiu Hei | | User profile editing and related flows. |
| CUHK email verification + 24h token expiry | Tam Yiu Hei | | Domain restriction + verification flow + anti-preload security. |
| Listings CRUD | Au Chi Hin | | Create/edit/delete listings + validations. |
| Image uploads | Au Chi Hin | | Active Storage. |
| Item status workflow | Au Chi Hin | | Available → Reserved → Sold. |
| Search & filtering | Lau Yat Laam | | Keyword search, filters, and fuzzy search. |
| Community posts | Lau Yat Laam | | Community feed, post CRUD, comments, UI polish, search, and fuzzy search. |
| ActionCable chat / notifications | Lau Chi Ho | | Real-time messaging + notifications over Redis. |
| User banning / suspension | Tam Yiu Hei | | Admin-controlled, time-limited bans. |
| Admin dashboard | Tam Yiu Hei | | User management + content moderation. |
| RSpec + SimpleCov | All members | | Shared testing effort across features. |
| Cucumber BDD scenarios | All members | | Shared acceptance testing across features. |


## Getting Started (Local)

### Prerequisites
- Ruby 3.4.7 (see `.ruby-version`)
- Bundler
- PostgreSQL
- Redis (required for ActionCable real-time chat + cache)

```bash
rbenv install 3.4.7
rbenv rehash
brew install postgresql
brew services start postgresql
brew install redis
brew services start redis
```

### Installation
```bash
git clone https://github.com/CSCI3100-Project-Group-9/CSCI3100-Project-Group-9.git
cd CSCI3100-Project-Group-9
bundle install
bin/rails db:create db:migrate
bin/rails db:seed   # optional: creates sample data
redis-server
bin/rails server
```

### Running Tests
```bash
bundle exec rspec
bundle exec cucumber
```

### Environment Variables
Create a `.env` file in the project root (see `.env.example` if present) with the following keys:

| Variable | Description |
| --- | --- |
| `GMAIL_ADDRESS` | Gmail sender address (OAuth2) |
| `GMAIL_CLIENT_ID` | Gmail OAuth2 client ID |
| `GMAIL_CLIENT_SECRET` | Gmail OAuth2 client secret |
| `UPSTASH_REDIS_URL` | Redis URL for production (Upstash) |
| `APP_HOST` | Production app hostname |
| `SECRET_KEY_BASE` | Rails secret key base |
