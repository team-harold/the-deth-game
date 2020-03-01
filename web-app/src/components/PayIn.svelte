<script>
    import { BigNumber } from 'ethers';

    import wallet from '../stores/wallet';
    import userPensionData from '../stores/userPensionData';
    import { everySecond } from '../stores/time';

    function getDateString(time) {
        let d = new Date(time)
        return d.toDateString()
    }

    function format(d) {
        return d ? getDateString(d.toNumber() * 1000) : ''
    }

    function bn(n) {
        return BigNumber.from(n);
    }

    $: retirementTime = $userPensionData.retirementTime;
    $: timestamp = BigNumber.from($everySecond).add($userPensionData.debug_timeDelta);
    $: deadline = 
       $userPensionData.contribution
        .div($userPensionData.payInPerMonth)
        .mul(bn(2629746)) // seconds in a month
        .add($userPensionData.startTime);

    $: catchup = $userPensionData.payInPerMonth.add($userPensionData.payInPerMonth.mul(timestamp.sub(deadline)).div(bn(2629746)));
    // needed params
    $: alive = false; // are you alive
    $: age=0; // how old you are
    $: dyingProbability= 0.5; //probability of dying at age

</script>

<style>
    h5 {
        color: #f7f7fa;
        font-size: 18px;
        margin: 0
    }

    h3 {
        color: #ff2968
    }

    #payin-btn {
        border-bottom: 1px solid #f2f2fa;
    }

    hr {
        margin-top: 1rem;
        margin-bottom: 1rem;
        border: 0;
        border-top: 2px solid #f7f7fa;
    }
</style>

<section class="d-flex flex-column action-section">
    {#if alive}

        <div class="d-flex flex-row justify-content-around my-1">
            <div class="d-flex flex-column align-items-center">
                <h2>{dyingProbability}%</h2>
                <h3>making it</h3>

            </div>
            <div class="d-flex flex-column align-items-center">
                <h2>{age}</h2>
                <h3>years old</h3>
            </div>
        </div>


        <hr/>

        {#if deadline.gt(timestamp)}
            <div class="d-flex flex-row align-items-center my-1">
                <span style="font-size: 18px; color: #00e8d5; padding-right: 10px">
                    <i class="fa fa-money-bill"></i>
                </span>
                    <h5>You next monthly payment is <span style="color: #ff2968">{$userPensionData.payInPerMonth}</span> DAI </h5>
            </div>
        {:else}
            <div class="d-flex flex-column align-items-center text-center my-1">
            <h1>  ⛔  </h1>
            <h5> You are {timestamp.sub(deadline).toNumber()}s late for you last payment.</h5> 
            <br>
            <h5>You are no longer in <span style="color: #ff2968">the deth game</span></h5>
            </div>
        {/if}

        <div class="d-flex flex-row align-items-center my-1">
            {#if deadline.gt(timestamp)}
                <span style="font-size: 18px; color: #00e8d5; padding-right: 10px">
                    <i class="fa fa-clock"></i>
                </span>
                <h5>Your Deadline is <span style="color: #ff2968">{format(deadline)}</span></h5>
                <div id="payin-btn" class="d-flex flex-column align-items-center py-5">
                    <button on:click="{() => wallet.tx({value: catchup}, 'Pension', 'payIn')}"> Make Payment </button>
                </div>
            {/if}
        </div>

    {:else}
        <div class="d-flex flex-column align-items-center my-1 text-center">
            <h1>👼</h1>
            <h5>You are no longer with us, we miss you</h5>
        </div>
    {/if}

</section>

<hr/>

<footer>
    <div class="d-flex flex-column align-items-center my-3">
        <h1>💰</h1>
        <h5> You total contribution is <span style="color: #ff2968">{$userPensionData.contribution}</span> DAI</h5>
        {#if timestamp.gt(retirementTime) && alive}
            <h5>You are retired but you just need to pay the remaining balance</h5> <!-- TODO calculate -->
        {:else}
            <h5>Retiring on... <span style="color: #ff2968">{format($userPensionData.retirementTime)}</span></h5>
        {/if}
    </div>
</footer>
