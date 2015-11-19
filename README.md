## Requirements

### Ruby 2.2.3
With rbenv
```
rbenv install 2.2.3
```

### Bundler 1.10.6
```
gem install bundler
bundle install
```

### GraphicsMagick
Either compile it from source, or use a package manager:

```
[aptitude | port | brew] install graphicsmagick
```

### Poppler
On Linux, use aptitude, apt-get or yum:

```
aptitude install poppler-utils poppler-data
```

On the Mac, you can install from source or use MacPorts:

```
sudo port install poppler | brew install poppler
```

## Usage

```
> DOMINION_USERNAME=username DOMINION_PASSWORD=password bundle exec ruby scrape.rb

Downloading bill.....
Parsing bill...

Billing information
Usage: 887kWh
Bill amount: $14.39
Service start date: 10/13/2015
Service end date: 11/12/2015
Bill due date: 12/08/2015
```

NOTE: It may take several seconds to parse the bill the first time you run the scraper
