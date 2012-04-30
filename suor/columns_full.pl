#!/usr/bin/perl
=pod Install and run as webserver
    curl get.mojolicio.us | sudo sh
    morbo columns.pl
=cut
use Mojolicious::Lite;
use List::Util qw(sum reduce);

# Параметры и входные данные
my @H = (36, 24, 16);
my $DEFAULT_DATA_URL = 'http://dymio.net/devmeetups_columns/source_array_json.txt';

# Route with placeholder
get '/' => sub {
    my $self = shift;
    my $data_url = $self->param('data_url') // $DEFAULT_DATA_URL;

    # Загружаем данные
    my $categories = $self->ua->get($data_url)->res->json;

    my @columns = columnize(3, $categories);

    $self->render("index", columns => \@columns);
};

app->start;


sub min_by {
    my $score = shift;
    reduce { $score->($a) <= $score->($b) ? $a : $b } @_;
}

sub columnize {
    my ($count, $categories) = @_;

    # Считаем высоту каждой колонки
    my @heights = map height(), @$categories;
    my $average = sum(@heights) / $count;

    # Функция оценки - сумма отклонений от среднего
    my $score = sub {
        sum map abs($_->{used} - $average), @{ shift() };
    };

    # Оптимистичная оценка неполного решения
    my $optimistic_score = sub {
        2 * sum grep $_ > 0, map $_->{used} - $average, @{ shift() };
    };

    # Конструктор состояния с новой категорией добавленной в колонку
    my $added = sub {
        my ($columns, $column, $index) = @_;
        my @columns = @$columns;
        $columns[$column] = {
            used => $columns[$column]{used} + $heights[$index],
            categories => [@{ $columns[$column]{categories} }, $index],
        };
        \@columns;
    };

    # Рекурсивная рабочая лошадка
    my $part;
    $part = sub {
        my ($columns, $index) = @_;

        if ($index == @heights) {
            $columns;
        } else {
            # Продуцируем все продолжения и выбираем лучшее
            min_by $score, map {
                $part->($added->($columns, $_, $index), $index + 1);
            } 0..$#$columns;

        }
    };

    # Конструируем начальное состояние
    my @empty_columns = map {used => 0, categories => []}, 1..$count;
    # Решаем задачу
    my $columns = $part->(\@empty_columns, 0);

    return map {[map $categories->[$_], @{ $_->{categories} }]} @$columns;
}

sub children() {
    @{ $_->{children} || [] }
}

sub height() {
    $H[0] +
    $H[1] * children +
    $H[2] * map children, children
}


__DATA__
@@ index.html.ep
<style type="text/css">
    ul,li,p {margin-top: 0; margin-bottom: 0}
    .categories {width: 33%; float: left}
    .categories p {white-space: nowrap; overflow: hidden; text-overflow: ellipsis;}
    .categories ul {list-style-type: none; margin: 0; }
    .categories ul > li > p {height: 36px; font-size: 28px}
    .categories ul ul > li > p {height: 24px; font-size: 16px}
    .categories ul ul ul > li > p {height: 16px; font-size: 12px}
</style>
% for (@$columns) {
    <div class="categories">
    %= include 'categories'
    </div>
% }

@@ categories.html.ep
<ul>
% for (@$_) {
    <li>
        <p><%= $$_{name} %></p>
        % if ($$_{children}) {
            %= include 'categories' for $$_{children};
        % }
    </li>
% }
</ul>
