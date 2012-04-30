#!/usr/bin/perl
=pod Install and run as webserver
    curl get.mojolicio.us | sudo sh
    morbo columns.pl
=cut
use Mojolicious::Lite;
use List::Util qw(sum);

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


sub columnize {
    my ($count, $categories) = @_;

    # Считаем высоту каждой колонки
    my @heights = map height(), @$categories;
    my $average = sum(@heights) / $count;

    # Сортируем высоты по убыванию, чтобы сначала пойти по жадной ветке
    my @is = sort {$heights[$b] <=> $heights[$a]} 0..$#heights;
    @heights = @heights[@is];
    my @categories = @$categories[@is];

    # Функция оценки - сумма отклонений от среднего
    my $score = sub {
        sum map abs($_->{used} - $average), @{ shift() };
    };

    # Оптимистичная оценка неполного решения
    my $optimistic_score = sub {
        2 * sum 0, grep $_ > 0, map $_->{used} - $average, @{ shift() };
    };

    # Конструктор состояния с новой категорией добавленной в колонку
    # Колонки поддерживаются в возрастающем по used порядке
    my $added = sub {
        my ($columns, $column, $index) = @_;
        my @columns = @$columns;

        # Вынимаем колонку из старого места
        my $removed = splice @columns, $column, 1;
        # ... обновляем
        my $updated =  {
            used => $$removed{used} + $heights[$index],
            categories => [@{ $$removed{categories} }, $index],
        };

        # ... и сдвигаем так чтобы сохранять порядок по used
        $column++ while $column <= $#columns
                    and $$updated{used} > $columns[$column]{used};
        splice @columns, $column, 0, $updated;

        \@columns;
    };

    my $best_so_far = undef;
    my $best_score_so_far = ($average * $count - $average) * 2 + 1;

    # Рекурсивная рабочая лошадка
    my $part;
    $part = sub {
        my ($columns, $index) = @_;

        if ($index == @heights) {
            # Нашли какое-то решение, запоминаем его если оно лучше известного
            my $this_score = $score->($columns);
            if ($this_score < $best_score_so_far) {
                $best_so_far = $columns;
                $best_score_so_far = $this_score;
            }
        } else {
            # Продуцируем все продолжения и выбираем лучшее
            for (0..$#$columns) {
                # Не пытаемся совать в колонку такой же наполненности как предыдущая
                next if $_ and $$columns[$_]{used} == $$columns[$_-1]{used};
                # Продуцируем продолжение решения
                my $next = $added->($columns, $_, $index);
                # Останавливаемся если оптимистичная оценка хуже уже найденой
                next if $optimistic_score->($next) >= $best_score_so_far;

                $part->($next, $index + 1);
            }
        }
    };

    # Конструируем начальное состояние
    my @empty_columns = map {used => 0, categories => []}, 1..$count;
    # Решаем задачу
    $part->(\@empty_columns, 0);
    my $columns = $best_so_far;

    return map [@categories[@{ $_->{categories} }]], @$columns;
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
